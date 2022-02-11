% módulo:
y_abs = abs(y_audio);

% Reamostragem (downsample) - de Ts do audio para Ts do sinal transmitido
y_up_int = intdump(y_abs, nsamp_audio);
% t_y_up_int = 0:Tb_x_up:(length(y_up_int)-1) * Tb_x_up;
t_y_up_int = linspace(0, T_audio, length(y_up_int));

% Demodulação em alta amostragem (Ts do sinal transmitido)
y_up_pam = (y_up_int * 2) - max(y_up_int);
y_up_demod = pamdemod(y_up_pam, M);

first_1 = find(y_up_demod == 1);
y_up = y_up_demod(first_1:(first_1 + (n * nsamp) - 1));
t_y_up = linspace(0, T_x, length(y_up));


% Reamostragem (downsample) - de Ts do sinal transmitido para Ts do sinal de informação
y_down = intdump(y_up, nsamp);

% Demodulação em baixa amostragem (Ts do sinal de informação)
y_pam = (y_down * 2) - max(y_down);
y_info = pamdemod(y_pam, M);

t_y_info = linspace(0, T_x, length(y_info));

%% --------- Gráficos:

% figure('Name', 'Sinal Recebido', 'Position', [img_ph img_pv img_w img_h])
%     plot(t_y_up_int, y_up_int, '*-r');
%     title('Sinal Recebido')
%     ylabel('Amplitude')
%     xlabel('Tempo [s]')
%     % ylim([-0.2 1.2])
%     % xlim([0 Tt*1.1])
%     grid on; hold on;

% figure('Name', 'Sinal Recebido PAM', 'Position', [img_ph img_pv img_w img_h])
%     plot(t_y_up_int, y_up_pam, '*-r');
%     title('Sinal Recebido PAM')
%     ylabel('Amplitude')
%     xlabel('Tempo [s]')
%     % ylim([-0.2 1.2])
%     % xlim([0 Tt*1.1])
%     grid on; hold on;

figure('Name', 'Sinal Recebido', 'Position', [img_ph img_pv img_w img_h])
subplot(211)
    plot(t_y_info, y_info, '*-r');
    title('Sinal de Informação Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt*1.1])
    grid on; hold on;
% figure('Name', 'Sinal Recebido PAM', 'Position', [img_ph img_pv img_w img_h])
subplot(212)
    plot(t_y_up, y_up, '*-r');
    title('Sinal Recebido Upsampled')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt*1.1])
    grid on; hold on;