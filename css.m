% # coding=utf8
%% 
% Transmissão de sinal com modulação CSS
% 
% Níveis [0,1]
clear all, close all;  clc;
%%
slCharacterEncoding('UTF-8')


%% ##############  Parametros de Entrada  ############## 
M = 2;                  % Nível da modulação
k = log2(M);            % bits por símbolo (=1 para M = 2)

nsamp = 4;              % Taxa de Oversampling
Ts = 100e-3;            % Período de amostragem
Fs = 1/Ts;              % Taxa de amostragem (amostras/s)
snr_p = 15;             % SNR em dB
n = 100*2^10;           % Numero de bits da Sequencia (Bitstream)


Rs = 1/Ts;      % Taxa de símbolos
Bw = Rs;        % Largura de banda do sinal
Rb = k*Rs;      % Taxa de bits por segundo
Tb = 1/Rb;      % Tempo de 1 bit [para pulsos retangulares] MODIFICAR
Tt = Tb*n;      % Tempo total do sinal

up_chirp = dsp.Chirp(...
    'SweepDirection', 'Unidirectional', ...
    'TargetFrequency', 10, ...
    'InitialFrequency', 0,...
    'TargetTime', 1, ...
    'SweepTime', 1, ...
    'SamplesPerFrame', 400, ...
    'SampleRate', 400);

down_chirp = dsp.Chirp(...
    'SweepDirection', 'Unidirectional', ...
    'TargetFrequency', 0, ...
    'InitialFrequency', 10,...
    'TargetTime', 1, ...
    'SweepTime', 1, ...
    'SamplesPerFrame', 400, ...
    'SampleRate', 400);

% Gera o Bitstream
x = randi([0,M-1],n,1);

x_mod = [];

for jj = 1 : length(x)
    if x(jj)
        x_mod(jj) = up_chirp()
    else
        x_mod(jj) = down_chirp()
    end
end

plot(x)