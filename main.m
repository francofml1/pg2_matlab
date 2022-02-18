%%
% Transmiss�o de sinal com modula��o OOK
%
% N�veis [0,1]

%% ############## INICIALIZA��O ##############

clear all, close all;
% clc;

% op_mode 0 -> carrega dados salvos
% op_mode 1 -> envia e aquisita novos dados e demodula
% op_mode 2 -> envia e aquisita novos dados e N�O demodula
op_mode = 0;

% dados_salvos = 'I:/Meu Drive/UFES/ENG EL�TRICA/10� Per�odo/Progeto de Gradua��o 2/Software/pg2_matlab/dados/220218144119n-55_Tb-0.1.mat';
% dados_salvos = 'E:/Franco/2S Drive/Documentos/PG2/dados/220210091708n-115_Tb-0.1.mat';
dados_salvos = './dados/2022_02_18_16_02_43_FULL_3n-153_Tb-0.1.mat';

% demod_mode 0 -> demodula��o com pot�ncia a cada Tb_x_up
% demod_mode 1 -> demodula��o m�ximos locais
% demod_mode 2 -> demodula��o com pamdemod
% demod_mode 3 -> demodula��o com pamdemod e todo o sinal - n�o pronto
demod_mode = 2;

% graph_enable = 0 => plota gr�ficos
% graph_enable = 1 => n�o plota gr�ficos
graph_enable = 1;

% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
img_ph = 800;
img_pv = 400;
line_w = 1.5;

if op_mode
    x_info_full = [];
    y_info_full = [];

    % Taxa de transmiss�o [amostras por segundo]
    % Rx_array = [1:0.1:19.9 20:1:30];
    Rx_array_base = [16:1:30];
    Rx_array = [];

    for freq = Rx_array_base
    Rx_array = [Rx_array ones(1,3)*freq];
    end

    % Rx_array = 10;
    for Rx = Rx_array
        %% ##############  PARAMETROS DE ENTRADA  ##############
        
        M = 2;                                      % N�vel da modula��o
        k = log2(M);                                % bits por s�mbolo (=1 para M = 2)
        n_ones_prefix = 1;                          % Quantidade de 1's do prefixo
        n_zeros_prefix = 0;                         % Quantidade de 0's do prefixo
        n_prefix = n_ones_prefix + n_zeros_prefix;  % Comprimento do prefixo
        n_msg = 50;                                 % Comprimento da mensagem
        n = n_msg + n_prefix;                       % Numero de bits da Sequencia (Bitstream)
        
        % Ft = 10;                % Taxa de transmiss�o [amostras/pulsos por segundo]
        Tb_x_up = 1/Rx;         % Tempo de bit do sinal transmitido
        Ts_x_up = Tb_x_up;      % Per�odo de amostragem do sinal transmitido
        Fs_x_up = 1 / Ts_x_up;  % Taxa de amostragem (amostras/s) do sinal transmitido
        nsamp = 4;              % Taxa de Oversampling
        
        Fs_min_audio = 44100;                               % m�nima taxa de amostragem do audio
        Fs_audio = Fs_x_up * ceil(Fs_min_audio/Fs_x_up);    % taxa de amostragem do audio
        Ts_audio = 1/Fs_audio;                              % per�odo de amostragem do audio
        recObj = audiorecorder(Fs_audio, 16, 1, 1);         % objeto para gravacao de audio
        nsamp_audio = Fs_audio / Fs_x_up;
        
        
        % Par�metros para ESP:
        start_delay = 2000;      % delay antes de iniciar trasmiss�o em [s]
        if (Tb_x_up > 30e-3)
            delay_t = Tb_x_up/2;    % delay para desligar a sa�da ap�s uma subida
        else
            delay_t = 15e-3;    % delay para desligar a sa�da ap�s uma subida
        end
        
        
        %% ############## TRANSMISS�O ##############
        
        % Sinal de informa��o (x_info):
        prefix = [ones(1, n_ones_prefix) zeros(1,n_zeros_prefix)];
        % x_rand = ones(n - n_prefix, 1);             % gera sequ�ncia de pulsos
        x_rand = randi([0,M-1],n - n_prefix,1);     % gera sequ�ncia aleat�ria
        x_info = [prefix x_rand'];
        
        % Reamostragem (upsample) - Sinal transmitido (x_up)
        x_up = rectpulse(x_info, nsamp);
        
        % Vetores de tempo
        T_x = nsamp * n * Tb_x_up;                       % Tempo total do sinal (transmitido e de informa��o)
        t_x_up = linspace(0, T_x, n * nsamp);    % vetor de tempo do sinal transmitido
        t_x_info = linspace(0, T_x, n);          % vetor de tempo do sinal de informa��o

        %% Converte para json e transmite � ESP:
        myMQTT = mqtt('tcp://localhost','ClientID','MatlabMQTT');       % objeto MQTT
        data_topic = 'd';                       % t�pico para publicacao de dados
        
        struct_data = struct('Tb', Tb_x_up, 'Td', delay_t, 'n', length(x_up), 'x_bit', x_up, 'sd', start_delay);
        json_data = jsonencode(struct_data);
        publish(myMQTT, data_topic, json_data, 'Retain', false)
        
        %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        %% ############## RECEP��O ##############
        if exist('start_delay')
            T_min_audio =  ceil(T_x + 0.5 + start_delay/1000);
        else
            T_min_audio =  ceil(T_x + 0.5 + 0.1);
        end
        T_audio = T_min_audio * ceil(T_min_audio*Fs_audio/nsamp_audio) / (T_min_audio*Fs_audio/nsamp_audio);
        
        % Recp��o por grava��o de �udio:
        fprintf('Iniciando grava��o de %.2f seg...\n', T_audio);
        recordblocking(recObj, T_audio);
        disp('Fim da grava��o');

        y_audio = getaudiodata(recObj)';



        if op_mode == 2
            %Salvar workspace:
            save('./dados/' + string(datestr(datetime('now'),'yyyy_mm_dd_HH_MM_SS')) + '__n-' + string(n) + '_Tb-' + string(Tb_x_up) + '.mat')
        else
            try
                demodulacao;
                if demod_mode == 3
                    x_info_full = [x_info_full x_info];
                    y_info_full = [y_info_full y_info];
                    
                    save('./dados/' + string(datestr(datetime('now'),'yyyy_mm_dd_HH_MM_SS')) + '_FULL_3n-' + string(3*n) + '_Tb-' + string(Tb_x_up) + '.mat')
                end
            catch
                save('./dados/' + string(datestr(datetime('now'),'yyyy_mm_dd_HH_MM_SS')) + '_FULL_3n-' + string(3*n) + '_Tb-' + string(Tb_x_up) + '.mat')
            end
        end % if op_mode ==2
    end % for Rx = Fs_array
    if demod_mode == 3
        [n_err, ber] = biterr(x_info_full, y_info_full);
        ber_est = 100 * n_err/n;

        fprintf('\nResultado final: \n');
        fprintf('n = %d; Tb_x_up = %.3f; n_err = %i;ber = %3f; BER = %.2f%%\n', n, Tb_x_up, n_err, ber, ber_est);

    end

    
    
else
    load(dados_salvos);
    graph_enable=1;

    demodulacao;
    
    % if exist('start_delay')
    %     T_audio =  ceil(T_x + 0.5 + start_delay/1000);
    % else
    %     T_audio =  ceil(T_x + 0.5 + 0.1);
    % end
end % if op_mode

