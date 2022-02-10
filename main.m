%%
% Transmissão de sinal com modulação OOK
%
% Níveis [0,1]

%% ############## INICIALIZAÇÃO ##############

clear all, close all;  clc;

% modo 0 -> carrega dados salvos
% modo 1 -> envia e aquisita novos dados
modo = 1;
dados_salvos = 'I:/Meu Drive/UFES/ENG ELÉTRICA/10º Período/Progeto de Graduação 2/Software/pg2_matlab/dados/n-215_Tb-0.1.mat';
% dados_salvos = './dados/n-25_Tb-1.mat';

% demod_modo 0 -> demodulação com potência a cada Tb
% demod_modo 1 -> demodulação máximos locais
demod_modo = 0;
 
% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
img_ph = 800;
img_pv = 400;
line_w = 1.5;

if modo
    myMQTT = mqtt('tcp://localhost','ClientID','MatlabMQTT');       % objeto MQTT
    data_topic = 'd';                       % tópico para publicacao de dados
    Fs_y = 44100;                           % taxa de amostragem do audio
    Ts_y = 1/Fs_y;                          % período de amostragem do audio
    recObj = audiorecorder(Fs_y, 16, 1, 1); % objeto para gravacao de audio
    
    
    %
    %% ##############  PARAMETROS DE ENTRADA  ##############
    
    M = 2;          % Nível da modulação
    k = log2(M);    % bits por símbolo (=1 para M = 2)
    n_prefix = 15;  % Comprimento do prefixo
    n_msg = 10;    % Comprimento da mensagem
    n = n_msg + n_prefix;         % Numero de bits da Sequencia (Bitstream)
    
    Tb = 100e-3;    % Tempo de bit
    Ts = Tb;        % Período de amostragem
    Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
    nsamp = 4;      % Taxa de Oversampling
    Tt = n * Tb;    % Tempo total do sinal
    
    % Vetores de tempo
    t_x = linspace(0, Tt, n);
    % Tb = t_x(2) - t_x(1);       % tempo de bit
    
    % Parâmetros para ESP:
    start_delay = 2000;      % delay antes de iniciar trasmissão em [s]
    if (Tb > 30e-3)
        delay_t = Tb/2;    % delay para desligar a saída após uma subida
    else
        delay_t = 15e-3;    % delay para desligar a saída após uma subida
    end
    
    
    %% ############## TRANSMISSÃO ##############
    
    % Sinal a ser transmitido:
    prefix = [ones(1, 10) zeros(1,5)];
    % x_rand = ones(n - n_prefix, 1);             % gera sequência de pulsos
    x_rand = randi([0,M-1],n - n_prefix,1);     % gera sequência aleatória
    x = [prefix x_rand'];
    
    % Reamostragem (upsample)
    x_up = rectpulse(x, nsamp);
    t_xup = linspace(0, Tt, n * nsamp);
    Tt_up = n * Tb * nsamp;
    
    %% Converte para json e transmite à ESP:
    struct_data = struct('Tb', Tb, 'Td', delay_t, 'n', n * nsamp, 'x_bit', x_up, 'sd', start_delay);
    json_data = jsonencode(struct_data);
    publish(myMQTT, data_topic, json_data, 'Retain', false)
    
    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    %% ############## RECEPÇÃO ##############
    if exist('start_delay')
        t_yrf =  Tt_up + 0.5 + start_delay/1000;
    else
        t_yrf =  Tt_up + 0.5 + 0.1;
    end
    
    % Recpção por gravação de áudio:
    fprintf('Iniciando gravação de %.2f seg...\n', t_yrf);
    recordblocking(recObj, t_yrf);
    disp('Fim da gravação');
else
    load(dados_salvos);
end % if modo

y_ruido = getaudiodata(recObj);

    
%% Análise no TEMPO
t_yr = linspace(0, t_yrf, length(y_ruido));

figure('Name', 'Sinal Original no Tempo', 'Position', [img_ph img_pv img_w img_h])
subplot(211)
    p1=plot(t_x, x, '*-b');
    title('Sinal Original')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt*1.1])
    grid on; hold on;
    % p1.LineWidth = 1.5;
    
subplot(212)
    p2=plot(t_xup, x_up, '.-b');
    % p2=plot(t_yr, y_demod, 'r');
    title('Sinal Original upsampled')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
%     xlim([0 Tt*1.1])
    grid on;
%     p2.LineWidth = 1.5;

% figure('Name', 'Sinal Recebido no Tempo', 'Position', [img_ph img_pv img_w img_h])
%     plot(t_yr,y_ruido,'r');
%     title('Sinal Recebido')
%     ylabel('Amplitude')
%     xlabel('Tempo [s]')
%     % ylim([-0.2 1.2])
%     % xlim([0 Tt*1.1])
%     grid on;


figure('Name', 'Sinais no Tempo - upsample', 'Position', [img_ph img_pv img_w img_h])
    p3=plot(t_yr, abs(y_ruido), 'r');
    title('Sinal Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    % ylim([-0.2 1.2])
    % xlim([0 Tt*1.1])
    grid on;
    % p3.LineWidth = 1.5;



%% Análise em FREQUÊNCIA

[Y_ruido, ~, f1, ~] = analisador_de_spectro(y_ruido', Ts_y);

% figure('Name', 'Sinal Recebido em Frequencia', 'Position', [img_ph img_pv img_w img_h])
%     plot(f1,10*log10(fftshift(abs(Y_ruido))),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoelétrico')
%     xlabel('Frequência [Hz]')
%     ylabel('PSD')

% figure('Name', 'Sinal Recebido Semilog', 'Position', [img_ph img_pv img_w img_h])
%     semilogx(f1,abs(Y_ruido),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoelétrico')
%     xlabel('Frequência')
%     ylabel('PSD')


%% Filtragem do sinal recebido:
% filtro(y_ruido, t_yr, [1.5e4], 21, 'high',Fs_y)


%% ############## DEMODULAÇÃO ##############
if demod_modo
    % Demodulação com máximos locais:
    demod_max_loc;
else
    % Demodulação com potência:
    demod_pot;
end

% Reamostragem (downsample)
y = intdump(y_up,nsamp);
t_y = 0:Tb:(length(y)-1)*Tb;

figure('Name', 'Sinal Recebido Downsaple', 'Position', [img_ph img_pv img_w img_h])
    plot(t_y, y, '*-r');
    title('Sinal Recebido Downsaple')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt*1.1])
    grid on; hold on;
    % p1.LineWidth = 1.5;


%% Salvar workspace:
% save('./dados/' + string(datestr(datetime('now'),'yymmddHHMMSS')) + 'n-' + string(n) + '_Tb-' + string(Tb_x_up) + '.mat')

%% Avaliação de Desempenho por BER
[n_err, ber] = biterr(x, y);
ber_est = 100 * n_err/n;

fprintf('n = %d; Tb = %.3f; n_err = %i;ber = %3f; BER = %.2f%%\n', n, Tb, n_err, ber, ber_est);
