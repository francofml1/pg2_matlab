%%
figure('Name', 'Sinal Original', 'Position', [img_ph img_pv img_w img_h])
    subplot(211)
        p1=plot(t_x_info, x_info, '*-b');
        title('Sinal de Informa��o Original')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
        xlim([0 t_x_info(end)])
        grid on; hold on;
        % p1.LineWidth = 1.5;
    subplot(212)
        p2=plot(t_x_up, x_up, '.-b');
        % p2=plot(t_y_audio, y_demod, 'r');
        title('Sinal Original upsampled - Transmitido')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
        xlim([0 t_x_up(end)])
        grid on;
    %     p2.LineWidth = 1.5;

%%
figure('Name', '??udio Gravado', 'Position', [img_ph img_pv img_w img_h])
    subplot(211)
        plot(t_y_audio,y_audio,'r');
        title('??udio Gravado')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        xlim([0 t_y_audio(end)])
        grid on;
    % figure('Name', 'Sinais no Tempo - upsample', 'Position', [img_ph img_pv img_w img_h])
    subplot(212)
        plot(t_y_audio, abs(y_audio), 'r');
        title('Modulo do sinal de �udio Gravado')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        % xlim([0 T_x*1.1])
        grid on;
        % p3.LineWidth = 1.5;

%%
figure('Name', 'Sinal Recebido em Frequencia', 'Position', [img_ph img_pv img_w img_h])
    plot(f1,10*log10(fftshift(abs(Y_audio))),'r'); 
    grid on;
    title('Sinal Recebido no Piezoel�trico')
    xlabel('Frequ�ncia [Hz]')
    ylabel('PSD')

%%
figure('Name', 'Sinal Recebido Semilog', 'Position', [img_ph img_pv img_w img_h])
    semilogx(f1,abs(Y_audio),'r'); 
    grid on;
    title('Sinal Recebido no Piezoel�trico')
    xlabel('Frequ�ncia')
    ylabel('PSD')

%%
figure('Name', 'Sinal Recebido', 'Position', [img_ph img_pv img_w img_h])
        plot(t_y_up_int, y_up_int, '*-r');
        title('Sinal Recebido')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        % xlim([0 Tt*1.1])
        grid on; hold on;

%%
figure('Name', 'Sinal Recebido PAM', 'Position', [img_ph img_pv img_w img_h])
        plot(t_y_up_int, y_up_pam, '*-r');
        title('Sinal Recebido PAM')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        % ylim([-0.2 1.2])
        % xlim([0 Tt*1.1])
        grid on; hold on;

%%
figure('Name', 'Sinal Recebido', 'Position', [img_ph img_pv img_w img_h])
    subplot(211)
        plot(t_y_info, y_info, '*-r');
        title('Sinal de Informa��o Recebido')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
        xlim([0 t_y_up(end)])
        grid on; hold on;
    % figure('Name', 'Sinal Recebido PAM', 'Position', [img_ph img_pv img_w img_h])
    subplot(212)
        plot(t_y_up, y_up, '*-r');
%         title('Sinal Recebido Upsampled')
        ylabel('Amplitude')
        xlabel('Tempo [s]')
        ylim([-0.2 1.2])
        xlim([0 t_y_up(end)])
        grid on; hold on;


%% Avalia��o de Desempenho por BER
[n_err, ber] = biterr(x_info, y_info);
ber_est = 100 * n_err/n;

fprintf('n = %d; Tb_x_up = %.3f; n_err = %i;ber = %3f; BER = %.2f%%\n', n, Tb_x_up, n_err, ber, ber_est);

%%
figure('Name', 'Compara��o', 'Position', [img_ph img_pv img_w img_h])
    p1=plot(t_x_info, x_info, '*--b');
    hold on;
    p2=plot(t_y_info, y_info, '+:r');
    title('Sinal de Informa��o Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt*1.1])
    grid on; hold on;

    p1.LineWidth = 2;
    p2.LineWidth = 1.5;