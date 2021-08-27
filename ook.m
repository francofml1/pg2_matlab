%% 
% Transmissão de sinal com modulação OOK
% 
% Níveis [0,1]
clear all, close all;  clc;

modo = 0    % sem loop
% modo = 1    % loop para cálcular SNR x BER

% config para graficos:
fator = 170;
img_w = 5 *fator;
img_h = 3 *fator;
line_w = 1.5;

%
%% ##############  Parametros de Entrada  ############## 
M = 2;                  % Nível da modulação
k = log2(M);            % bits por símbolo (=1 para M = 2)
n = 3e5;                % Numero de bits da Sequencia (Bitstream)
nsamp = 4;              % Taxa de Oversampling
Ts = 100e-3;            % Período de amostragem
Fs = 1/Ts;              % Taxa de amostragem (amostras/s)

snr_p = 20;              % SNR em dB
% Rb = 1.41e6;            % Taxa de bits por segundo (para codificação digital de audio, conforme PCM);
% Fs = 44e3;              % Taxa de amostragem designada pelo padrão

% Calculos preliminares

% Tb = 1/Rb;      % Tempo de 1 bit [para pulsos retangulares]
% Tt = Tb*n;      % Tempo total do sinal
% Rs = Rb/k;      % Taxa de simbolos (boud rate) [symb/s]
% Bw = Rs;        % Largura de banda do sinal
% Ts = 1/Rs;      % Periodo de amostragem - baseado na taxa de simbolo - que eh baseada na largura de banda do sistema

Rs = 1/Ts;      % Taxa de símbolos
Bw = Rs;        % Largura de banda do sinal
Rb = k*Rs;      % Taxa de bits por segundo
Tb = 1/Rb;      % Tempo de 1 bit [para pulsos retangulares]
Tt = Tb*n;      % Tempo total do sinal

t = linspace(0, Tb*n, n);
t_up = linspace(0, Tb * n, n * nsamp);

%% ############## Simulaусo do Sistema ############## 

%
%%  ############## TRANSMISS├O ############## 
%
% Gera o Bitstream
x = randi([0,M-1],n,1);

% Modulaусo (M-PAM)
xmod = pammod(x,M); % mapeamento 
xmod = (xmod + 1) / 2;

% Reamostragem (upsample)
x_up = rectpulse(xmod, nsamp);

%% ------------ Vetor SNR --------------
% snr = linspace(1, 15, 100); % snr variando de 1 a 100 com 100 amostras

% cрlculo de SNR vs BER teзrico
EbNo_for = 0:.1:20;
ber = berawgn(EbNo_for,'pam',M);



%% variaусo SNR, BER
% ber_awgn = zeros(size(EbNo_for));
for o = 1 : length(EbNo_for)
    
    EsNo = EbNo_for(o) + 10 * log10(k);
    snr(o) = EsNo - 10 * log10(nsamp) + 3 + 3; % era pra ser sз +3


    %%  ##############  CANAL  ############## 
        % Adiciona ruьdo Gaussiano branco ao sinal
        y_ruido = awgn(x_up, snr(o),'measured');


        %%  ############## RECEPК├O  ############## 
        % Reamostragem (downsample)
        y_down = intdump(y_ruido,nsamp);

        % Demodulaусo (M-PAM)
        y_down = (y_down * 2) - 1;
        y = pamdemod(y_down,M); % Desmapeamento
        % y = y_down;


    %%  ############## Calcula os erros  ############## 
    d_bit = (abs(x-y));
    n_erros(o) = sum(d_bit);
    ber_awgn(o) = mean(d_bit);
    clear d_bit;

end
%% -------------- OBS --------------
% se o sinal for um sinal de voz, SNR = 1e-3 eh suficiente
% 
% numero de amostras: n = 3000 -> n = 3*(1/BER)

%% ------------------------ Mostra alguns Grрficos ------------------------

% %%  ##############  Resultados calculados  ############## 
% fprintf('Grandezas de avaliacao do canal\n');
% fprintf('SNR: %4.3f dB\n',snr);
% fprintf('BER: %5.3e \n',ber_awgn);
% fprintf('Qtd de erros: %3d\n',n_erros);


%  Plota a relaусo SNR vs BER
% plot(snr, ber_awgn, 'o'), hold on
% plot(snr, ber_awgn)
% plot(EbNo_for, ber), hold all
figure('Name','SNR vs BER') 
s1=semilogy(EbNo_for, ber, '-*b'); hold all
s2=semilogy(snr, ber_awgn, '.r');
    title('Relacao SNR vs BER')
    xlabel('SNR')
    ylabel('BER')
    legend('Teзrico', 'Simulado')
    grid on, hold off;
    s1.LineWidth = 1.5;
    s2.LineWidth = 1.5;
%%

% Plota os sinais no dominio do Tempo
figure('Name', 'Sinais no Tempo')
%     p1=plot(real(x_up(1:nsamp*50)),'b'); % plota o sinal modulado
    p1=plot(real(x_up(1:nsamp*50)),'b'); % plota o sinal modulado
    hold all
    p2=plot(real(y_ruido(1:nsamp*50)),'r'); % plota o sinal ruidoso
    hold off, grid on
    title('Sinais no Tempo')
    p1.LineWidth = 1.5;
    p2.LineWidth = 1.3;
    legend('Sinal Modulado', 'Sinal Ruidoso')
    xlabel('Tempo')
    ylabel('Amplitude')
%%
% h1 = eyediagram(real(x_up),3*nsamp,1,0);
% 
% set(h1,'Name','Diagram de Olho x_{up}');
% title('Diagrama de olho de x_{up}'), grid on


%%% Diagrama de olho
% h2 = eyediagram(real(y_ruido),2*nsamp,1,0);
% 
% set(h2,'Name','Diagram de Olho y_{ruido}');
% title('Diagrama de olho de y_{ruido}'), grid on


% Mostra o diagram de olho na saьda do canal
% if nsamp == 1
%     offset = 0;
%     h2 = eyediagram(real(y_down),2,1,offset);
% else
%     offset = 2;
%     h2 = eyediagram(real(y_down),3,1,offset);
% end

% set(h2,'Name','Diagram de Olho sem Offset');
% grid on


% Mostra o Diagrama de Constelaусo
% scatterplot(y_down)
% grid on




%%  ############## Analise no dominio da frequencia ############## 
% [Xmod,~,f1,~] = analisador_de_spectro(xmod',Ts);
% [Y_ruido,~,f2,~] = analisador_de_spectro(y_ruido',Ts/4);
% [X_up,~,f3,~] = analisador_de_spectro(x_up',Ts/4);

% figure('Name', 'Sinais em Frequencia')
% subplot(3,1,1)
%     plot(f1,10*log10(fftshift(abs(Xmod))),'b'); grid on; % plot no domьnio da frequencia
%     title('Sinal Modulado'), xlabel('FrequЖncia [Hz]'), ylabel('PSD')
% subplot(3,1,2)
%     plot(f2,10*log10(fftshift(abs(Y_ruido))),'r'); grid on; % plot no domьnio da frequencia
%     title('Sinal Ruidoso'), xlabel('FrequЖncia [Hz]'), ylabel('PSD')
% subplot(3,1,3)
%     plot(f3,10*log10(fftshift(abs(X_up))),'r'); grid on; % plot no domьnio da frequencia
%     title('Sinal Modulado com Up Sample'), xlabel('FrequЖncia [Hz]'), ylabel('PSD')