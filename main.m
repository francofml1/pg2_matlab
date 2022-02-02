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
recObj = audiorecorder(44100, 16, 1, 1);% objeto para gravacao de audio

% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
line_w = 1.5;

%
%% ##############  Parametros de Entrada  ##############
M = 2;          % Nível da modulação
k = log2(M);    % bits por símbolo (=1 para M = 2)
n_prefix = 15;  % Comprimento do prefixo
n_msg = 400;    % Comprimento da mensagem
n = n_msg + n_prefix;         % Numero de bits da Sequencia (Bitstream)

Tb = 35e-3;    % Tempo de bit
Ts = Tb;        % Período de amostragem
Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
nsamp = Fs_y / Fs;      % Taxa de Oversampling
Tt = n * Tb;    % Tempo total do sinal

% Vetores de tempo
t_x = linspace(0, Tt, n);
% t_xup = linspace(0, Tt, n * nsamp);

% Parâmetros para ESP:
if (Tb > 30e-3)
    delay_t = Tb/2;    % delay para desligar a saída após uma subida
else
    delay_t = 15e-3;    % delay para desligar a saída após uma subida
end

% Sinal a ser transmitido:
prefix = [ones(1, 10) zeros(1,5)];
% x_rand = ones(n - n_prefix, 1);             % gera sequência de pulsos
x_rand = randi([0,M-1],n - n_prefix,1);     % gera sequência aleatória
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
y = getaudiodata(recObj);
% y_demod = pamdemod(y, M);

%% Análise no TEMPO
t_y = linspace(0, Tt * 1.1, length(y));

figure('Name', 'Sinal Original no Tempo', 'Position', [50 50 img_w img_h])
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
% % p2=plot(t(1:50), y(1:50), 'r');
%     p2=plot(t_xup, x_up, '.-b');
%     % p2=plot(t_y, y_demod, 'r');
%     title('Sinal Original upsampled')
%     ylabel('Amplitude')
%     xlabel('Tempo [ms]')
%     ylim([-0.2 1.2])
%     xlim([0 Tt*1.1])
%     grid on;
%     p2.LineWidth = 1.5;

figure('Name', 'Sinal Recebido no Tempo', 'Position', [50 50 img_w img_h])
    plot(t_y,y,'r');
    title('Sinal Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    % ylim([-0.2 1.2])
    xlim([0 Tt*1.1])
    grid on;


% figure('Name', 'Sinais no Tempo - upsample', 'Position', [50 50 img_w img_h])
%     p3=plot(t_y, abs(y), 'r');
%     title('Sinal Recebido')
%     ylabel('Amplitude')
%     xlabel('Tempo [ms]')
%     % ylim([-0.2 1.2])
%     xlim([0 Tt*1.1])
%     grid on;
%     % p3.LineWidth = 1.5;



%% Análise em FREQUÊNCIA


[Y, ~, f1, ~] = analisador_de_spectro(y', Ts_y);

figure('Name', 'Sinal Recebido em Frequencia', 'Position', [50 50 img_w img_h])
    plot(f1,10*log10(fftshift(abs(Y))),'r'); 
    grid on;
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência [Hz]')
    ylabel('PSD')

figure('Name', 'Sinal Recebido Semilog', 'Position', [50 50 img_w img_h])
    semilogx(f1,abs(Y),'r'); 
    grid on;
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência')
    ylabel('PSD')


%% Filtragem dos sinais

ordem = 21;                 % Ordem do filtro 
% fct_Hz = 45e3;            % Frequencia de corte do filtro [Hz]
fct_Hz = [1.5e4];   % Frequencia de corte do filtro [Hz]
% fct1 = 0.015;             % Frequencia de corte do filtro (normalizado de -Fs/2 até Fs/2
                            % ou seja, a frequencia de corte em Hz é fcorte1*Fs/2
fct1 = fct_Hz / (Fs_y/2)    % Frequencia de corte do filtro (normalizado de -Fs/2 até Fs/2
h_tipo = 'high';

% Geração do filtro
if (length(fct1) > 1)
    h = fir1(ordem, fct1, 'bandpass');
else
    h = fir1(ordem, fct1, h_tipo);
end
    
figure('Name', 'Resposta do Filtro'), 
    freqz(h, 1, n) % Plota a resposta do filtro

y_filt = filter(h,1,y)';   % implementado como uma convolucao entre sinal e filtro

%$ Medição do Espectro do sinal filtrado
[Y_filt, ~, f1_filt, ~] = analisador_de_spectro(y_filt, Ts_y);

figure('Name', 'Sinais em Frequencia', 'Position', [50 50 img_w img_h])
    subplot(2,2,1)
        plot(f1,10*log10(fftshift(abs(Y))),'r'); 
        grid on;
        title('Sinal Recebido no Piezoelétrico')
        xlabel('Frequência [Hz]')
        ylabel('PSD')
    subplot(2,2,3)
        plot(f1_filt, 10*log10(fftshift(abs(Y_filt))),'k'); 
        grid on;
        title('Sinal Recebido no Piezoelétrico FILTRADO')
        xlabel('Frequência [Hz]')
        ylabel('PSD')

% figure('Name', 'Sinais no Tempo', 'Position', [50 50 img_w img_h])
subplot(222)
    p3 = plot(t_y, (y), 'r');
    title('Sinal Recebido no Piezoelétrico')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p3.LineWidth = 1.5;
subplot(224)
    p4 = plot(t_y, (y_filt), 'k');
    title('Sinal Recebido no Piezoelétrico FILTRADO')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p4.LineWidth = 1.5;



%% Encontra picos:
[pks,locs] = findpeaks(y,t_y,'MinPeakDistance',Tb/2,'MinPeakHeight',.1);

figure('Name', 'Identificação dos Picos', 'Position', [50 50 img_w img_h])
findpeaks(y,t_y,'MinPeakDistance',Tb/2,'MinPeakHeight',.1);
% text(locs+.02,pks,num2str((1:numel(pks))'));
locs = locs - locs(1);
locs_rd = roundtowardvec(locs,t_x);

y_out = zeros(size(x));
for index = 1:length(locs_rd)
    y_out(find(t_x == (locs_rd(index)))) = 1;
end

figure('Name', 'Tratado', 'Position', [50 50 img_w img_h])
    plot(t_x, y_out,'*-r'); 
    grid on;
    title('Sinal Tratado')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
    ylim([-0.2 1.2])





%%
[pks,locs] = findpeaks(y,t_y,'MinPeakDistance',Tb/2,'MinPeakHeight',.1);

% locs = locs - locs(1)
% locs_rd = roundtowardvec(locs,t_x)

y_out2 = zeros(size(y));
for index = 1:length(locs)
    y_out2(find(t_y == (locs(index)))) = 1;
end

figure('Name', 'Tratado', 'Position', [50 50 img_w img_h])
    plot(t_y, y_out2,'*-r'); 
    grid on;
    title('Sinal Tratado')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
    ylim([-0.2 1.2])

%% Salvar workspace:
% save('n-'+string(n)+'_Tb-'+string(Tb))