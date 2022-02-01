%%
% Transmiss�o de sinal com modula��o OOK
%
% N�veis [0,1]

%% ############## Inicializa��o ##############
clear all, close all;  clc;

myMQTT = mqtt('tcp://localhost');       % objeto MQTT
data_topic = 'd';                       % t�pico para publicacao de dados
Fs_audio = 44100;                       % taxa de amostragem do audio
recObj = audiorecorder(44100, 16, 1, 1) % objeto para gravacao de audio

% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
line_w = 1.5;

%
%% ##############  Parametros de Entrada  ##############
M = 2;          % N�vel da modula��o
k = log2(M);    % bits por s�mbolo (=1 para M = 2)
n_prefix = 15;  % Comprimento do prefixo
n_msg = 100;    % Comprimento da mensagem
n = n_msg + n_prefix;         % Numero de bits da Sequencia (Bitstream)

Tb = 100e-3;    % Tempo de bit
Ts = Tb;        % Per�odo de amostragem
Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
nsamp = Fs_audio / Fs;      % Taxa de Oversampling
Tt = n * Tb;    % Tempo total do sinal

% Vetores de tempo
t_x = linspace(0, Tt, n);
t_xup = linspace(0, Tt, n * nsamp);

% Par�metros para ESP:
if (Tb > 30e-3)
    delay_t = Tb/2;    % delay para desligar a sa�da ap�s uma subida
else
    delay_t = 15e-3;    % delay para desligar a sa�da ap�s uma subida
end

% Sinal a ser transmitido:
prefix = [ones(1, 10) zeros(1,5)];
% x = [prefix ones(1, n - n_prefix)];             % gera sequ�ncia de pulsos
x_rand = randi([0,M-1],n - n_prefix,1);     % gera sequ�ncia aleat�ria
x = [prefix x_rand'];

% Reamostragem (upsample)
x_up = rectpulse(x, nsamp);

%% Converte para json e transmite � ESP:
struct_data = struct('Tb', Tb, 'Td', delay_t, 'n', n, 'x_bit', x);
json_data = jsonencode(struct_data);
publish(myMQTT, data_topic, json_data, 'Retain', false)


%% Recp��o por grava��o de �udio:
disp('Iniciando grava��o')
recordblocking(recObj, Tt + 0.2);
disp('Fim da grava��o');

%% Demodula��o:
y = getaudiodata(recObj);
y_demod = pamdemod(y, M);

%% Gr�ficos
t_y = linspace(0, Tt * 1.1, length(y));
figure()
plot(t_y,y);
grid on;

figure('Name', 'Sinais no Tempo - upsample', 'Position', [50 50 img_w img_h])
subplot(211)
    p1=plot(t_x, x, '.-b');
    title('Sinal Original')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.2 1.2])
    xlim([0 Tt*1.1])
    grid on; hold on;
    p1.LineWidth = 1.5;
    
subplot(212)
% p2=plot(t(1:50), y(1:50), 'r');
    p2=plot(t_xup, x_up, '.-b');
    % p2=plot(t_y, y_demod, 'r');
    title('Sinal Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.2 1.2])
    xlim([0 Tt*1.1])
    grid on;
    p2.LineWidth = 1.5;

figure('Name', 'Sinais no Tempo - upsample', 'Position', [50 50 img_w img_h])
    p3=plot(t_y, abs(y), 'b');
    title('Sinal Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    % ylim([-0.2 1.2])
    xlim([0 Tt*1.1])
    grid on;
    % p3.LineWidth = 1.5;