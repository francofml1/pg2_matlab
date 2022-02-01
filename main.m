%%
% Transmissão de sinal com modulação OOK
%
% Níveis [0,1]

clear all, close all;  clc;
myMQTT= mqtt('tcp://localhost');
data_topic = 'd';

%%
% config para graficos:
fator = 170;
img_w = 5 * fator;
img_h = 3 * fator;
line_w = 1.5;

%
%% ##############  Parametros de Entrada  ##############
M = 2;          % Nível da modulação
k = log2(M);    % bits por símbolo (=1 para M = 2)
n = 50;   % Numero de bits da Sequencia (Bitstream)

nsamp = 4;      % Taxa de Oversampling
Ts = 100e-3;    % Período de amostragem
Tb = Ts;        % Tempo de bit
Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
snr_p = 15;     % SNR em dB


% #### Parâmetros para ESP:
if (Tb > 30e-3)
    delay_t = Tb/2;    % delay para desligar a saída após uma subida
else
    delay_t = 15e-3;    % delay para desligar a saída após uma subida
end


% x = randi([0,M-1],n,1);     % gera sequência aleatória
x = ones(1, n);

struct_data = struct('Tb', Tb, 'Td', delay_t, 'n', n, 'x_bit', x);
json_data = jsonencode(struct_data);

publish(myMQTT, data_topic, json_data, 'Retain', false)

%% Recpção por gravação de áudio:
% recObj = audiorecorder(44100,16,1)

% %%
% disp('Start speaking.')
% recordblocking(recObj, 5);
% disp('End of Recording.');

% %%
% play(recObj);

% %%
% close all
% y = getaudiodata(recObj);
% t = linspace(0, 5, length(y));
% plot(t,y);
% grid on;
