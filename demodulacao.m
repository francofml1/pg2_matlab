
    
%% Análise no TEMPO
t_y_audio = linspace(0, T_audio, length(y_audio));  % vetor de tempo do audio gravado
% t_y_audio = 0:Tb_x_up:T_audio;  % vetor de tempo do audio gravado

if graph_enable
    figure('Name', 'Sinal Original', 'Position', [img_ph img_pv img_w img_h])
    subplot(211)
        p1=plot(t_x_info, x_info, '*-b');
        title('Sinal de Informação Original')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
        % xlim([0 T_x*1.1])
        grid on; hold on;
        % p1.LineWidth = 1.5;
    subplot(212)
        p2=plot(t_x_up, x_up, '.-b');
        % p2=plot(t_y_audio, y_demod, 'r');
        title('Sinal Original upsampled - Transmitido')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
    %     xlim([0 T_x*1.1])
        grid on;
    %     p2.LineWidth = 1.5;

    figure('Name', 'Áudio Gravado', 'Position', [img_ph img_pv img_w img_h])
    subplot(211)
        plot(t_y_audio,y_audio,'r');
        title('Áudio Gravado')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        % xlim([0 T_x*1.1])
        grid on;
    % figure('Name', 'Sinais no Tempo - upsample', 'Position', [img_ph img_pv img_w img_h])
    subplot(212)
        plot(t_y_audio, abs(y_audio), 'r');
        title('Modulo do sinal de áudio Gravado')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        % xlim([0 T_x*1.1])
        grid on;
        % p3.LineWidth = 1.5;
end % if graph_enable


%% Análise em FREQUÊNCIA

[Y_audio, ~, f1, ~] = analisador_de_spectro(y_audio, Ts_audio);

% figure('Name', 'Sinal Recebido em Frequencia', 'Position', [img_ph img_pv img_w img_h])
%     plot(f1,10*log10(fftshift(abs(Y_audio))),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoelétrico')
%     xlabel('Frequência [Hz]')
%     ylabel('PSD')

% figure('Name', 'Sinal Recebido Semilog', 'Position', [img_ph img_pv img_w img_h])
%     semilogx(f1,abs(Y_audio),'r'); 
%     grid on;
%     title('Sinal Recebido no Piezoelétrico')
%     xlabel('Frequência')
%     ylabel('PSD')


%% Filtragem do sinal recebido:
% filtro(y_audio, t_y_audio, [1.5e4], 21, 'high',Fs_audio)


%% ############## DEMODULAÇÃO ##############
if demod_mode == 0
    % Demodulação com potência:
    demod_pot;
elseif demod_mode == 1
    % Demodulação com máximos locais:
    demod_max_loc;
elseif demod_mode == 2 || demod_mode == 3
    % Demodulação com pamdemod:
    demod_pamdemod;
end

%%
% figure('Name', 'Sinal Recebido Downsaple', 'Position', [img_ph img_pv img_w img_h])
%     plot(t_y, y, '*-r');
%     title('Sinal Recebido Downsaple')
%     ylabel('Amplitude')
%     xlabel('Tempo [s]')
%     ylim([-0.2 1.2])
%     % xlim([0 T_x*1.1])
%     grid on; hold on;
%     % p1.LineWidth = 1.5;

%% Avaliação de Desempenho por BER
[n_err, ber] = biterr(x_info, y_info);
ber_est = 100 * n_err/n;

fprintf('n = %d; Tb_x_up = %.3f; n_err = %i;ber = %3f; BER = %.2f%%\n', n, Tb_x_up, n_err, ber, ber_est);