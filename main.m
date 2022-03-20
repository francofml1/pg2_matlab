%%
% Transmiss�o de sinal com modula��o OOK
%
% N�veis [0,1]

%% ############## INICIALIZA��O ##############

clear all, close all;
% clc;

% op_mode 0 -> carrega dados salvos
% op_mode 1 -> envia e aquisita novos dados
op_mode = 0;
% dados_salvos = 'I:/Meu Drive/UFES/ENG EL�TRICA/10� Per�odo/Progeto de Gradua��o 2/Software/pg2_matlab/dados/n-215_Tb-0.1.mat';
dados_salvos = './dados1/n-65_Tb-0.2.mat';

% demod_mode 0 -> demodula��o com pot�ncia a cada Tb_x_up
% demod_mode 1 -> demodula��o m�ximos locais
% demod_mode 2 -> demodula��o com pamdemod
demod_mode = 2;

% graph_disable = 0 => plota gr�ficos
% graph_disable = 1 => n�o plota gr�ficos
graph_disable = 1;

% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
img_ph = 800;
img_pv = 400;
line_w = 1.5;

if op_mode
    %% ##############  PARAMETROS DE ENTRADA  ##############
    
    M = 2;                                      % N�vel da modula��o
    k = log2(M);                                % bits por s�mbolo (=1 para M = 2)
    n_ones_prefix = 3;                          % Quantidade de 1's do prefixo
    n_zeros_prefix = 2;                         % Quantidade de 0's do prefixo
    n_prefix = n_ones_prefix + n_zeros_prefix;  % Comprimento do prefixo
    n_msg = 20;                                 % Comprimento da mensagem
    n = n_msg + n_prefix;                       % Numero de bits da Sequencia (Bitstream)
    
    Tb_x_up = 100e-3;               % Tempo de bit do sinal transmitido
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
    % publish(myMQTT, data_topic, json_data, 'Retain', false)
    
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
else
    load(dados_salvos);

    if exist('start_delay')
        T_audio =  ceil(T_x + 0.5 + start_delay/1000);
    else
        T_audio =  ceil(T_x + 0.5 + 0.1);
    end
end % if op_mode

%%
y_audio = getaudiodata(recObj)';

    
%% An�lise no TEMPO
t_y_audio = linspace(0, T_audio, length(y_audio));  % vetor de tempo do audio gravado
% t_y_audio = 0:Tb_x_up:T_audio;  % vetor de tempo do audio gravado

if graph_disable
    figure('Name', 'Sinal Original', 'Position', [img_ph img_pv img_w img_h])
    subplot(211)
        p1=plot(t_x_info, x_info, '*-b');
        title('Sinal de Informa��o Original')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
        % xlim([0 T_x*1.1])
        grid on; hold on;
        % p1.LineWidth = 1.5;
    subplot(212)
        p2=plot(t_x_up, x_up, '.-b');
        % p2=plot(t_y_audio, y_demod, 'r');
        title('Sinal Original upsampled - Transmitido')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
    %     xlim([0 T_x*1.1])
        grid on;
    %     p2.LineWidth = 1.5;

    figure('Name', '�udio Gravado', 'Position', [img_ph img_pv img_w img_h])
    subplot(211)
        plot(t_y_audio,y_audio,'r');
        title('�udio Gravado')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        % xlim([0 T_x*1.1])
        grid on;
    % figure('Name', 'Sinais no Tempo - upsample', 'Position', [img_ph img_pv img_w img_h])
    subplot(212)
        plot(t_y_audio, abs(y_audio), 'r');
        title('Modulo do sinal de �udio Gravado')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        % xlim([0 T_x*1.1])
        grid on;
        % p3.LineWidth = 1.5;
end % if graph_disable


%% An�lise em FREQU�NCIA

[Y_audio, ~, f1, ~] = analisador_de_spectro(y_audio, Ts_audio);

% figure('Name', 'Sinal Recebido em Frequencia', 'Position', [img_ph img_pv img_w img_h])
%     plot(f1,10*log10(fftshift(abs(Y_audio))),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoel�trico')
%     xlabel('Frequ�ncia [Hz]')
%     ylabel('PSD')

% figure('Name', 'Sinal Recebido Semilog', 'Position', [img_ph img_pv img_w img_h])
%     semilogx(f1,abs(Y_audio),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoel�trico')
%     xlabel('Frequ�ncia')
%     ylabel('PSD')


%% Filtragem do sinal recebido:
% filtro(y_audio, t_y_audio, [1.5e4], 21, 'high',Fs_audio)


%% ############## DEMODULA��O ##############
if demod_mode == 0
    % Demodula��o com pot�ncia:
    demod_pot;
elseif demod_mode == 1
    % Demodula��o com m�ximos locais:
    demod_max_loc;
elseif demod_mode == 2
    % Demodula��o com pamdemod:
    demod_pamdemod;
end

%%
% figure('Name', 'Sinal Recebido Downsaple', 'Position', [img_ph img_pv img_w img_h])
%     plot(t_y, y, '*-r');
%     title('Sinal Recebido Downsaple')
%     ylabel('Amplitude')
%     xlabel('Tempo [s]')
%     ylim([-0.2 1.2])
%     % xlim([0 T_x*1.1])
%     grid on; hold on;
%     % p1.LineWidth = 1.5;


%% Salvar workspace:
% save('./dados/' + string(datestr(datetime('now'),'yymmddHHMMSS')) + 'n-' + string(n) + '_Tb-' + string(Tb_x_up) + '.mat')

%% Avalia��o de Desempenho por BER
[n_err, ber] = biterr(x_info, y_info);
ber_est = 100 * n_err/n;

fprintf('n = %d; Tb_x_up = %.3f; n_err = %i;ber = %3f; BER = %.2f%%\n', n, Tb_x_up, n_err, ber, ber_est);
