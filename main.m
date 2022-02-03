%%
% Transmissão de sinal com modulação OOK
%
% Níveis [0,1]

%% ############## Inicialização ##############
clear all, close all;  clc;

myMQTT = mqtt('tcp://localhost');       % objeto MQTT
data_topic = 'd';                       % tópico para publicacao de dados
Fs_y = 44100;                           % taxa de amostragem do audio
Ts_y = 1/Fs_y;                          % período de amostragem do audio
recObj = audiorecorder(Fs_y, 16, 1, 1); % objeto para gravacao de audio

% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
img_ph = 800;
img_pv = 400;
line_w = 1.5;

%
%% ##############  Parametros de Entrada  ##############
M = 2;          % Nível da modulação
k = log2(M);    % bits por símbolo (=1 para M = 2)
n_prefix = 15;  % Comprimento do prefixo
n_msg = 50;    % Comprimento da mensagem
n = n_msg + n_prefix;         % Numero de bits da Sequencia (Bitstream)

Tb = 100e-3;    % Tempo de bit
Ts = Tb;        % Período de amostragem
Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
nsamp = Fs_y / Fs;      % Taxa de Oversampling
Tt = n * Tb;    % Tempo total do sinal

% Vetores de tempo
t_x = linspace(0, Tt, n);
% Tb = t_x(2) - t_x(1);       % tempo de bit
% t_xup = linspace(0, Tt, n * nsamp);

% Parâmetros para ESP:
if (Tb > 30e-3)
    delay_t = Tb/2;    % delay para desligar a saída após uma subida
else
    delay_t = 15e-3;    % delay para desligar a saída após uma subida
end

% Sinal a ser transmitido:
prefix = [ones(1, 15)]% zeros(1,5)];
x_rand = ones(n - n_prefix, 1);             % gera sequência de pulsos
% x_rand = randi([0,M-1],n - n_prefix,1);     % gera sequência aleatória
x = [prefix x_rand'];

% Reamostragem (upsample)
% x_up = rectpulse(x, nsamp);

%% Converte para json e transmite à ESP:
struct_data = struct('Tb', Tb, 'Td', delay_t, 'n', n, 'x_bit', x);
json_data = jsonencode(struct_data);
publish(myMQTT, data_topic, json_data, 'Retain', false)


%% Recpção por gravação de áudio:
disp('Iniciando gravação')
recordblocking(recObj, Tt + 0.5);
disp('Fim da gravação');

%% Demodulação:
y_ruido = getaudiodata(recObj);
% y_demod = pamdemod(y_ruido, M);

%% Análise no TEMPO
t_yr = linspace(0, Tt * 1.1, length(y_ruido));

figure('Name', 'Sinal Original no Tempo', 'Position', [img_ph img_pv img_w img_h])
    % subplot(211)
    p1=plot(t_x, x, '*-b');
    title('Sinal Original')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.2 1.2])
    xlim([0 Tt*1.1])
    grid on; hold on;
    % p1.LineWidth = 1.5;
    
% subplot(212)
% % p2=plot(t(1:50), y_ruido(1:50), 'r');
%     p2=plot(t_xup, x_up, '.-b');
%     % p2=plot(t_yr, y_demod, 'r');
%     title('Sinal Original upsampled')
%     ylabel('Amplitude')
%     xlabel('Tempo [ms]')
%     ylim([-0.2 1.2])
%     xlim([0 Tt*1.1])
%     grid on;
%     p2.LineWidth = 1.5;

figure('Name', 'Sinal Recebido no Tempo', 'Position', [img_ph img_pv img_w img_h])
    plot(t_yr,y_ruido,'r');
    title('Sinal Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    % ylim([-0.2 1.2])
    xlim([0 Tt*1.1])
    grid on;


% figure('Name', 'Sinais no Tempo - upsample', 'Position', [img_ph img_pv img_w img_h])
%     p3=plot(t_yr, abs(y_ruido), 'r');
%     title('Sinal Recebido')
%     ylabel('Amplitude')
%     xlabel('Tempo [ms]')
%     % ylim([-0.2 1.2])
%     xlim([0 Tt*1.1])
%     grid on;
%     % p3.LineWidth = 1.5;



%% Análise em FREQUÊNCIA

[Y_ruido, ~, f1, ~] = analisador_de_spectro(y_ruido', Ts_y);

figure('Name', 'Sinal Recebido em Frequencia', 'Position', [img_ph img_pv img_w img_h])
    plot(f1,10*log10(fftshift(abs(Y_ruido))),'r'); 
    grid on;
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência [Hz]')
    ylabel('PSD')

figure('Name', 'Sinal Recebido Semilog', 'Position', [img_ph img_pv img_w img_h])
    semilogx(f1,abs(Y_ruido),'r'); 
    grid on;
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência')
    ylabel('PSD')


% filtro(y_ruido, t_yr, [1.5e4], 21, 'high',Fs_y)

%% Encontra picos:
[pks,locs] = findpeaks(y_ruido,t_yr,'MinPeakDistance',Tb/2,'MinPeakHeight',.1);

% figure('Name', 'Identificação dos Picos', 'Position', [img_ph img_pv img_w img_h])
% findpeaks(y_ruido,t_yr,'MinPeakDistance',Tb/2,'MinPeakHeight',.1);
% text(locs+.02,pks,num2str((1:numel(pks))'));

y_up = zeros(size(y_ruido));
for index = 1:length(locs)
    y_up(find(t_yr == (locs(index)))) = 1;
end

t_yr = t_yr -  locs(1);
%%
Tb_y = locs(2) - locs(1);
t_y = 0:Tb:t_yr(end);
y = zeros(size(t_y));
idx_ti = 1;
soma=[];
for ii = 1:length(y)
    % tib = ii * Tb;
    tib = t_yr(idx_ti);
    tfb = tib + Tb
    aux = find(t_yr >= tfb);
    if length(aux)
        idx_tf = aux(1) - 1;
    else
        idx_tf = length(t_yr);
    end
    
    soma(ii) = sum(y_up(idx_ti:idx_tf));
    if (soma(ii) > 0)
        y(ii) = 1;
    end
    
    idx_ti = idx_tf;
end


figure('Name', 'Tratado upsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(t_yr, y_up,'*-r'); 
    grid on;
    title('Sinal Tratado')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
    ylim([-0.2 1.2])

figure('Name', 'Tratado Downsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(t_y, y,'*-r'); 
    grid on;
    title('Sinal Tratado')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
    ylim([-0.2 1.2])


disp('1`s de x: ' + string(sum(x(:) == 1)))
disp('1`s de y: ' + string(sum(y_up(:) == 1)))


%% Salvar workspace:
% save('n-'+string(n)+'_Tb-'+string(Tb)+'.mat')

%% Avaliação de Desempenho via BER versus SNR
% [qtd,BER] = biterr(de2bi(data_in),de2bi(data_out));

