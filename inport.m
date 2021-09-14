clear all, close all, clc;


% config para graficos:
fator = 170;
img_w = 5 *fator;
img_h = 3 *fator;
line_w = 1.5;


%% Importação de dados

load('ALL0067TEK');                 % Carrega dados do osciloscópio:
t1 = F0067CH1.VarName4 * 1e-12;     % tempo em segundos
x1 = F0067CH1.VarName5 * 1e-5;      % amplitude em Volts
t2 = F0067CH2.VarName4 * 1e-12;     % tempo em segundos
x2 = F0067CH2.VarName5 * 1e-5;      % amplitude em Volts

n = length(t1);
Ts = t1(2) - t1(1);     % Periodo de amostragem
Fs = 1/Ts;      % Taxa de amostragem

ordem   = 21;               % Ordem do filtro 
% fct_Hz = 100;               % Frequencia de corte do filtro [Hz]
fct_Hz = [490 499];               % Frequencia de corte do filtro [Hz]
% fct1 = 0.015;             % Frequencia de corte do filtro (normalizado de -Fs/2 até Fs/2
                            % ou seja, a frequencia de corte em Hz é fcorte1*Fs/2
fct1 = fct_Hz / (Fs/2);     % Frequencia de corte do filtro (normalizado de -Fs/2 até Fs/2


% Medição do Espectro
[X1, ~, f1, ~] = analisador_de_spectro(x1', Ts);
[X2, ~, f2, ~] = analisador_de_spectro(x2', Ts);

%% Sinais originais

figure('Name', 'Sinais no Tempo', 'Position', [50 50 img_w img_h])
subplot(211)
    p1 = plot(t2, x2, 'b')
    title('Sinal transmitido a solenoide')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p1.LineWidth = 1.5;
subplot(212)
    p2 = plot(t1, x1, 'r')
    title('Sinal Recebido no Piezoelétrico')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p2.LineWidth = 1.5;

figure('Name', 'Sinais em Frequencia', 'Position', [50 50 img_w img_h])
subplot(2,1,1)
    plot(f1,10*log10(fftshift(abs(X1))),'b'); 
    grid on; % plot no domínio da frequencia
    title('Sinal transmitido a solenoide')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
subplot(2,1,2)
    plot(f2,10*log10(fftshift(abs(X2))),'r'); 
    grid on; % plot no domínio da frequencia
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência [Hz]')
    ylabel('PSD')


%% Geração do filtro passa baixas
if (length(fct1) > 1)
    h = fir1(ordem, fct1, 'bandpass'); 
else
    h = fir1(ordem, fct1); 
end
    
figure('Name', 'Resposta do Filtro'), 
freqz(h,1,n)  % Plota a resposta do filtro


%% Filtragem dos sinais
x1_filt = filter(h,1,x1);   % implementado como uma convolucao entre sinal e filtro

%$ Medição do Espectro do sinal filtrado
[X1_filt, ~, f1_filt, ~] = analisador_de_spectro(x1_filt', Ts);

figure('Name', 'Sinais em Frequencia', 'Position', [50 50 img_w img_h])
subplot(2,1,1)
    plot(f2,10*log10(fftshift(abs(X2))),'b'); 
    grid on; % plot no domínio da frequencia
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
subplot(2,1,2)
    plot(f1_filt, 10*log10(fftshift(abs(X1_filt))),'r'); 
    grid on; % plot no domínio da frequencia
    title('Sinal Recebido no Piezoelétrico FILTRADO')
    xlabel('Frequência [Hz]')
    ylabel('PSD')



figure('Name', 'Sinais no Tempo', 'Position', [50 50 img_w img_h])
subplot(211)
    p3 = plot(t1, x1, 'b')
    title('Sinal Recebido no Piezoelétrico')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p3.LineWidth = 1.5;
subplot(212)
    p4 = plot(t1, x1_filt, 'r')
    title('Sinal Recebido no Piezoelétrico FILTRADO')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p4.LineWidth = 1.5;
