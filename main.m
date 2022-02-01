%%
% Transmiss�o de sinal com modula��o OOK
%
% N�veis [0,1]

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
M = 2;          % N�vel da modula��o
k = log2(M);    % bits por s�mbolo (=1 para M = 2)
n = 50;   % Numero de bits da Sequencia (Bitstream)

nsamp = 4;      % Taxa de Oversampling
Ts = 100e-3;    % Per�odo de amostragem
Tb = Ts;        % Tempo de bit
Fs = 1 / Ts;    % Taxa de amostragem (amostras/s)
snr_p = 15;     % SNR em dB


% #### Par�metros para ESP:
if (Tb > 30e-3)
    delay_t = Tb/2;    % delay para desligar a sa�da ap�s uma subida
else
    delay_t = 15e-3;    % delay para desligar a sa�da ap�s uma subida
end


% x = randi([0,M-1],n,1);     % gera sequ�ncia aleat�ria
x = ones(1, n);

struct_data = struct('Tb', Tb, 'Td', delay_t, 'n', n, 'x_bit', x);
json_data = jsonencode(struct_data);

publish(myMQTT, data_topic, json_data, 'Retain', false)

%% Recp��o por grava��o de �udio:
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
