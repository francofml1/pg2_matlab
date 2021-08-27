%% 
% Transmiss�o de sinal com modula��o OOK
% 
% N�veis [0,1]
clear all, close all;  clc;
%%

% modo = 0    % sem loop
modo = 1    % loop para c�lcular SNR x BER
iteracoes = 1000;


% config para graficos:
fator = 170;
img_w = 5 *fator;
img_h = 3 *fator;
line_w = 1.5;

%
%% ##############  Parametros de Entrada  ############## 
M = 2;                  % N�vel da modula��o
k = log2(M);            % bits por s�mbolo (=1 para M = 2)
n = 1*2^10;            % Numero de bits da Sequencia (Bitstream)
nsamp = 4;              % Taxa de Oversampling
Ts = 100e-3;            % Per�odo de amostragem
Fs = 1/Ts;              % Taxa de amostragem (amostras/s)
snr_p = 5;              % SNR em dB

% Rb = 1.41e6;            % Taxa de bits por segundo (para codifica��o digital de audio, conforme PCM);
% Fs = 44e3;              % Taxa de amostragem designada pelo padr�o

% Calculos preliminares

% Tb = 1/Rb;      % Tempo de 1 bit [para pulsos retangulares]
% Tt = Tb*n;      % Tempo total do sinal
% Rs = Rb/k;      % Taxa de simbolos (boud rate) [symb/s]
% Bw = Rs;        % Largura de banda do sinal
% Ts = 1/Rs;      % Periodo de amostragem - baseado na taxa de simbolo - que eh baseada na largura de banda do sistema

Rs = 1/Ts;      % Taxa de s�mbolos
Bw = Rs;        % Largura de banda do sinal
Rb = k*Rs;      % Taxa de bits por segundo
Tb = 1/Rb;      % Tempo de 1 bit [para pulsos retangulares]
Tt = Tb*n;      % Tempo total do sinal

t = linspace(0, Tb*n, n);
t_up = linspace(0, Tb * n, n * nsamp);

%% ############## Simula��o do Sistema ############## 

%
%%  ############## TRANSMISS�O ############## 
%
% Gera o Bitstream
x = randi([0,M-1],n,1);

% Modula��o (M-PAM)
    % xmod = pammod(x,M); % mapeamento 
    % xmod = (xmod + 1) / 2;
    % for ii = 1 : length(x)
    %     if x(ii) < 0
    %         x(ii) = 0;
    %     end
    % end

% Reamostragem (upsample)
% x_up = rectpulse(xmod, nsamp);
x_up = rectpulse(x, nsamp);




if modo
    %% ------------ Vetor SNR --------------
    
    % c�lculo de SNR vs BER te�rico
    EbNo_for = 0:.1:15;
    ber_teorico = berawgn(EbNo_for,'pam',M);
    n_erros=zeros(size(EbNo_for));
    
    for o = 1 : length(EbNo_for)
        
        EsNo = EbNo_for(o) + 10 * log10(k);
        snr(o) = EsNo - 10 * log10(nsamp) + 3 + 3; % era pra ser s� +3
        snr_p = snr(o);
        
        nerr = 0;
        for kiter=1:iteracoes
            x = randi([0,M-1],n,1);
            
            
            %%% primeiro m�todo
            % x_up = rectpulse(x, nsamp);

                
            % %%  ##############  CANAL  ############## 
            % % Adiciona ru�do Gaussiano branco ao sinal
            % y_ruido = awgn(x_up, snr(o),'measured');

            % %%  ############## RECEP��O  ############## 
            % % Demodula��o (OOK)
            % y_up = zeros(n,1);
            % for jj = 1 : length(y_ruido)
            %     if y_ruido (jj) < 0.5
            %         y_up(jj) = 0;
            %     else
            %         y_up(jj) = 1;
            %     end
            % end

            % % Reamostragem (downsample)
            % y = intdump(y_up, nsamp);
            %%% primeiro m�todo - end
            
            %%% segundo m�todo
            % Modula��o (M-PAM)
            xmod = pammod(x,M); % mapeamento 
            xmod = (xmod + 1) / 2;
           
            % Reamostragem (upsample)
            x_up = rectpulse(xmod, nsamp);

            % Adiciona ru�do Gaussiano branco ao sinal
            y_ruido = awgn(x_up, snr(o),'measured');


            % % Reamostragem (downsample)
            y_down = intdump(y_ruido,nsamp);

            % Demodula??o (M-PAM)
            y_down = (y_down * 2) - 1;
            y = pamdemod(y_down,M); % Desmapeamento

            %%% segundo m�todo - end
            
        
            %%  ############## Calcula os erros  ############## 
            d_bit = (abs(x-y));
            n_erros(o) = n_erros(o) + sum(d_bit);
            ber_awgn(o) = mean(d_bit);
            clear d_bit;

            nerr = nerr + sum(abs(x-y));
        end
        BER(o) = nerr/(n*k*nsamp*iteracoes);
        fprintf("Simulados %d pontos, BER = %f, SNR = %f\n",(n*iteracoes*nsamp),BER(o),snr(o));
        fprintf("N�mero de erros: %d\n\n", nerr);
    
    end % for
    y_up = rectpulse(y, nsamp);


    %  Plota a rela��o SNR vs BER
    % figure('Name','SNR vs BER') 
    % s1=semilogy(EbNo_for, ber_teorico, 'b'); hold all
    % s2=semilogy(snr, ber_awgn, 'r');
    % title('Relacao SNR vs BER')
    % xlabel('SNR')
    % ylabel('BER')
    % legend('Te�rico', 'Simulado')
    % grid on, hold off;
    % s1.LineWidth = 1.5;
    % s2.LineWidth = 1.5;
    %%
    figure('Name','SNR vs BER') 
    s1=semilogy(EbNo_for, ber_teorico, 'b'); hold all
    s2=semilogy(snr, BER, 'r');
    title('Relacao SNR vs BER')
    xlabel('SNR')
    ylabel('BER')
    legend('Te�rico', 'Simulado')
    grid on, hold off;
    s1.LineWidth = 1.5;
    s2.LineWidth = 1.5;
    %%

else % ############################################################
    
    %%  ##############  CANAL  ############## 
    % Adiciona ru�do Gaussiano branco ao sinal
    y_ruido = awgn(x_up, snr_p,'measured');
    
    %%  ############## RECEP��O  ############## 
    y_up = zeros(n,1);
    for jj = 1 : length(y_ruido)
        if y_ruido (jj) < 0.5
            y_up(jj) = 0;
        else
            y_up(jj) = 1;
        end
    end
    % Reamostragem (downsample)
    y = intdump(y_up,nsamp);
    
    % % Reamostragem (downsample)
    % y_down = intdump(y_ruido,nsamp);

    % % Demodula??o (M-PAM)
    % y_down = (y_down * 2) - 1;
    % y = pamdemod(y_down,M); % Desmapeamento
    
    
    %%  ############## Calcula os erros  ############## 
    d_bit = (abs(x-y));
    n_erros = sum(d_bit);
    ber_awgn = mean(d_bit);
    %%  ##############  Resultados calculados  ############## 
    fprintf('Grandezas de avaliacao do canal\n');
    fprintf('SNR: %4.3f dB\n',snr_p);
    fprintf('BER: %5.3e \n',ber_awgn);
    fprintf('Qtd de erros: %3d\n',n_erros);
end
%%

% Plota os sinais no dominio do Tempo

figure('Name', 'Sinais no Tempo - upsample', 'Position', [50 50 img_w img_h])
subplot(211)
    p1=plot(t_up(1:50*nsamp), x_up(1:50*nsamp), 'b');
    title('Sinal Original')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.2 1.2])
    grid on;
    p1.LineWidth = 1.5;
    
subplot(212)
% p2=plot(t(1:50), y(1:50), 'r');
    p2=plot(t_up(1:50*nsamp), y_up(1:50*nsamp), 'r');
    title('Sinal Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.3 1.2])
    grid on;
    p2.LineWidth = 1.5;

%%
figure('Name', 'Sinais no Tempo', 'Position', [50 50 img_w img_h])
    p1=plot(t_up(1:nsamp*50), x_up(1:nsamp*50),'b'); % plota o sinal modulado
    hold all
    p2=plot(t_up(1:nsamp*50), y_ruido(1:nsamp*50),'r'); % plota o sinal ruidoso
    hold off, grid on
    title("Sinais no Tempo para SNR = " + snr_p + " dB")
    p1.LineWidth = 1.5;
    p2.LineWidth = 1.3;
    legend('Sinal Modulado', 'Sinal Ruidoso', 'location', 'southeast')
    xlabel('Tempo [ms]')
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


% Mostra o diagram de olho na sa�da do canal
% if nsamp == 1
%     offset = 0;
%     h2 = eyediagram(real(y_down),2,1,offset);
% else
%     offset = 2;
%     h2 = eyediagram(real(y_down),3,1,offset);
% end

% set(h2,'Name','Diagram de Olho sem Offset');
% grid on


% Mostra o Diagrama de Constela��o
% scatterplot(y_down)
% grid on




%%  ############## Analise no dominio da frequencia ############## 
% [Xmod,~,f1,~] = analisador_de_spectro(xmod',Ts);
% [Y_ruido,~,f2,~] = analisador_de_spectro(y_ruido',Ts/4);
% [X_up,~,f3,~] = analisador_de_spectro(x_up',Ts/4);

% figure('Name', 'Sinais em Frequencia')
% subplot(3,1,1)
%     plot(f1,10*log10(fftshift(abs(Xmod))),'b'); grid on; % plot no dom�nio da frequencia
%     title('Sinal Modulado'), xlabel('Frequ�ncia [Hz]'), ylabel('PSD')
% subplot(3,1,2)
%     plot(f2,10*log10(fftshift(abs(Y_ruido))),'r'); grid on; % plot no dom�nio da frequencia
%     title('Sinal Ruidoso'), xlabel('Frequ�ncia [Hz]'), ylabel('PSD')
% subplot(3,1,3)
%     plot(f3,10*log10(fftshift(abs(X_up))),'r'); grid on; % plot no dom�nio da frequencia
%     title('Sinal Modulado com Up Sample'), xlabel('Frequ�ncia [Hz]'), ylabel('PSD')