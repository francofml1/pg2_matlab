clear all, close all, clc;

%%
% config para graficos:
fator = 170;
img_w = 5 *fator;
img_h = 3 *fator;
line_w = 1.5;

n_ch = 1;
img_num = '0052';
img_path = '..\..\Imagens Osciloscopio\ALL';

%% Importação de dados
img_path_CH1 = strcat(img_path, img_num, '\F', img_num, 'CH1.CSV');
CH1 = importfile(img_path_CH1);
% load('ALL0053TEK');                 % Carrega dados do osciloscópio:
t1 = CH1.VarName4% * 1e-12;     % tempo em segundos
x1 = CH1.VarName5% * 1e-5;      % amplitude em Volts
if (n_ch == 2)
    img_path_CH2 = strcat(img_path, img_num, '\F', img_num, 'CH2.CSV');
    CH2 = importfile(img_path_CH2);
    t2 = CH2.VarName4 * 1e-12;     % tempo em segundos
    x2 = CH2.VarName5 * 1e-5;      % amplitude em Volts
end

n = length(t1);
Ts = t1(2) - t1(1);     % Periodo de amostragem
Fs = 1/Ts;      % Taxa de amostragem

ordem   = 21;               % Ordem do filtro 
% fct_Hz = 45e3;               % Frequencia de corte do filtro [Hz]
fct_Hz = [9000 11000];               % Frequencia de corte do filtro [Hz]
% fct1 = 0.015;             % Frequencia de corte do filtro (normalizado de -Fs/2 até Fs/2
                            % ou seja, a frequencia de corte em Hz é fcorte1*Fs/2
fct1 = fct_Hz / (Fs/2);     % Frequencia de corte do filtro (normalizado de -Fs/2 até Fs/2
h_tipo = 'low';


% Medição do Espectro
[X1, ~, f1, ~] = analisador_de_spectro(x1', Ts);
if (n_ch == 2)
    [X2, ~, f2, ~] = analisador_de_spectro(x2', Ts);
end

%% Sinais originais

figure('Name', 'Sinais no Tempo', 'Position', [50 50 img_w img_h])
if (n_ch == 2)
subplot(211)
    p1 = plot(t2, x2, 'b')
    title('Sinal transmitido a solenoide')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p1.LineWidth = 1.5;
subplot(212)
end
    p2 = plot(t1, x1, 'r')
    title('Sinal Recebido no Piezoelétrico')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p2.LineWidth = 1.5;

figure('Name', 'Sinais em Frequencia', 'Position', [50 50 img_w img_h])
if (n_ch == 2)
subplot(2,1,1)
    plot(f2,10*log10(fftshift(abs(X2))),'b'); 
    grid on;
    title('Sinal transmitido a solenoide')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
subplot(2,1,2)
end
    plot(f1,10*log10(fftshift(abs(X1))),'r'); 
    grid on;
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência [Hz]')
    ylabel('PSD')

figure('Name', 'Sinal Recebido Semilog', 'Position', [50 50 img_w img_h])
    semilogx(f1,abs(X1),'r'); 
    grid on;
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência')
    ylabel('PSD')


%% Geração do filtro passa baixas
if (length(fct1) > 1)
    h = fir1(ordem, fct1, 'bandpass'); 
else
    h = fir1(ordem, fct1, h_tipo); 
end
    
figure('Name', 'Resposta do Filtro'), 
freqz(h,1,n)  % Plota a resposta do filtro


%% Filtragem dos sinais
x1_filt = filter(h,1,x1)';   % implementado como uma convolucao entre sinal e filtro

%$ Medição do Espectro do sinal filtrado
[X1_filt, ~, f1_filt, ~] = analisador_de_spectro(x1_filt, Ts);

figure('Name', 'Sinais em Frequencia')%, 'Position', [50 50 img_w img_h])
subplot(2,2,1)
    plot(f1,10*log10(fftshift(abs(X1))),'b'); 
    grid on; % plot no domínio da frequencia
    title('Sinal Recebido no Piezoelétrico')
    xlabel('Frequência [Hz]')
    ylabel('PSD')
subplot(2,2,3)
    plot(f1_filt, 10*log10(fftshift(abs(X1_filt))),'r'); 
    grid on; % plot no domínio da frequencia
    title('Sinal Recebido no Piezoelétrico FILTRADO')
    xlabel('Frequência [Hz]')
    ylabel('PSD')



% figure('Name', 'Sinais no Tempo', 'Position', [50 50 img_w img_h])
subplot(222)
    p3 = plot(t1, (x1), 'b')
    title('Sinal Recebido no Piezoelétrico')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p3.LineWidth = 1.5;
subplot(224)
    p4 = plot(t1, (x1_filt), 'r')
    title('Sinal Recebido no Piezoelétrico FILTRADO')
    ylabel('Amplitude [V]')
    xlabel('Tempo [s]')
    grid on;
    axis tight
    p4.LineWidth = 1.5;

% Decodifica��o
%  y1 = pamdemod(abs(x1)-(max(x1)/2),2)
