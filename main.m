%%
% Transmiss?o de sinal com modula??o OOK
%
% N?veis [0,1]

%% ############## INICIALIZA??O ##############

clear all, close all;  clc;

% modo 0 -> carrega dados salvos
% modo 1 -> envia e aquisita novos dados
modo = 1;
dados_salvos = 'I:/Meu Drive/UFES/ENG EL?TRICA/10? Per?odo/Progeto de Gradua??o 2/Software/pg2_matlab/dados/n-215_Tb-0.1.mat';
% dados_salvos = './dados/n-25_Tb-1.mat';

% demod_modo 0 -> demodula??o com pot?ncia a cada Tb
% demod_modo 1 -> demodula??o m?ximos locais
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
    data_topic = 'd';                       % t?pico para publicacao de dados
    Fs_y = 44100;                           % taxa de amostragem do audio
    Ts_y = 1/Fs_y;                          % per?odo de amostragem do audio
    recObj = audiorecorder(Fs_y, 16, 1, 1); % objeto para gravacao de audio
    
    
    %
    %% ##############  PARAMETROS DE ENTRADA  ##############
    
    M = 2;          % N?vel da modula??o
    k = log2(M);    % bits por s?mbolo (=1 para M = 2)
    n_prefix = 15;  % Comprimento do prefixo
    n_msg = 10;    % Comprimento da mensagem
    n = n_msg + n_prefix;         % Numero de bits da Sequencia (Bitstream)
    
    Tb = 100e-3;    % Tempo de bit
    Ts = Tb;        % Per?odo de amostragem
    Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
    nsamp = 4;      % Taxa de Oversampling
    Tt = n * Tb;    % Tempo total do sinal
    
    % Vetores de tempo
    t_x = linspace(0, Tt, n);
    % Tb = t_x(2) - t_x(1);       % tempo de bit
    
    % Par?metros para ESP:
    start_delay = 2000;      % delay antes de iniciar trasmiss?o em [s]
    if (Tb > 30e-3)
        delay_t = Tb/2;    % delay para desligar a sa?da ap?s uma subida
    else
        delay_t = 15e-3;    % delay para desligar a sa?da ap?s uma subida
    end
    
    
    %% ############## TRANSMISS?O ##############
    
    % Sinal a ser transmitido:
    prefix = [ones(1, 10) zeros(1,5)];
    % x_rand = ones(n - n_prefix, 1);             % gera sequ?ncia de pulsos
    x_rand = randi([0,M-1],n - n_prefix,1);     % gera sequ?ncia aleat?ria
    x = [prefix x_rand'];
    
    % Reamostragem (upsample)
    x_up = rectpulse(x, nsamp);
    t_xup = linspace(0, Tt, n * nsamp);
    Tt_up = n * Tb * nsamp;
    
    %% Converte para json e transmite ? ESP:
    struct_data = struct('Tb', Tb, 'Td', delay_t, 'n', n * nsamp, 'x_bit', x_up, 'sd', start_delay);
    json_data = jsonencode(struct_data);
    publish(myMQTT, data_topic, json_data, 'Retain', false)
    
    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    %% ############## RECEP??O ##############
    if exist('start_delay')
        t_yrf =  Tt_up + 0.5 + start_delay/1000;
    else
        t_yrf =  Tt_up + 0.5 + 0.1;
    end
    
    % Recp??o por grava??o de ?udio:
    fprintf('Iniciando grava??o de %.2f seg...\n', t_yrf);
    recordblocking(recObj, t_yrf);
    disp('Fim da grava??o');
else
    load(dados_salvos);
end % if modo

y_ruido = getaudiodata(recObj);

    
%% An?lise no TEMPO
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



%% An?lise em FREQU?NCIA

[Y_ruido, ~, f1, ~] = analisador_de_spectro(y_ruido', Ts_y);

% figure('Name', 'Sinal Recebido em Frequencia', 'Position', [img_ph img_pv img_w img_h])
%     plot(f1,10*log10(fftshift(abs(Y_ruido))),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoel?trico')
%     xlabel('Frequ?ncia [Hz]')
%     ylabel('PSD')

% figure('Name', 'Sinal Recebido Semilog', 'Position', [img_ph img_pv img_w img_h])
%     semilogx(f1,abs(Y_ruido),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoel?trico')
%     xlabel('Frequ?ncia')
%     ylabel('PSD')


%% Filtragem do sinal recebido:
% filtro(y_ruido, t_yr, [1.5e4], 21, 'high',Fs_y)


%% ############## DEMODULA??O ##############
if demod_modo
    % Demodula??o com m?ximos locais:
    demod_max_loc;
else
    % Demodula??o com pot?ncia:
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
% save('./dados/n-'+string(n)+'_Tb-'+string(Tb)+'.mat')

%% Avalia??o de Desempenho por BER
[n_err, ber] = biterr(x, y);
ber_est = 100 * n_err/n;

fprintf('n = %d; Tb = %.3f; n_err = %i;ber = %3f; BER = %.2f%%\n', n, Tb, n_err, ber, ber_est);
