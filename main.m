%%
% Transmissão de sinal com modulação OOK
%
% Níveis [0,1]

%% ############## Inicialização ##############
clear all, close all;  clc;

myMQTT = mqtt('tcp://localhost');       % objeto MQTT
data_topic = 'd';                       % tópido para publicacao de dados
recObj = audiorecorder(44100, 16, 1, 1) % objeto para gravacao de audio

% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
line_w = 1.5;

%
%% ##############  Parametros de Entrada  ##############
M = 2;          % Nível da modulação
k = log2(M);    % bits por símbolo (=1 para M = 2)
n = 10;         % Numero de bits da Sequencia (Bitstream)

nsamp = 4;      % Taxa de Oversampling
Tb = 100e-3;    % Tempo de bit
Ts = Tb/nsamp;  % Período de amostragem
Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
snr_p = 15;     % SNR em dB
Tt = n * Tb;    % Tempo total do sinal

% #### Parâmetros para ESP:
if (Tb > 30e-3)
    delay_t = Tb/2;    % delay para desligar a saída após uma subida
else
    delay_t = 15e-3;    % delay para desligar a saída após uma subida
end

% Sinal a ser transmitido:
% x = ones(1, n);             % gera sequência de pulsos
x = randi([0,M-1],n,1);     % gera sequência aleatória

% Converte para json e transmite à ESP:
struct_data = struct('Tb', Tb, 'Td', delay_t, 'n', n, 'x_bit', x);
json_data = jsonencode(struct_data);
publish(myMQTT, data_topic, json_data, 'Retain', false)


%% Recpção por gravação de áudio:
disp('Iniciando gravação')
recordblocking(recObj, Tt + 0.2);
disp('Fim da gravação');

%%
close all
y = getaudiodata(recObj);
t = linspace(0, Tt * 1.1, length(y));
figure()
plot(t,y);
grid on;
