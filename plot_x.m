clear all, 
close all;
%%

dados_salvos = './dados/2022_02_18_17_32_56_FULL_3n-153_Tb-0.0625.mat';

load(dados_salvos);


%%

figure('Name', 'Sinal Original', 'Position', [img_ph img_pv img_w img_h])
subplot(211)
    p1=plot(t_x_info, x_info, '*-b');
    title('Sinal de Informação')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    xlim([0 t_x_info(end)])
    grid on; hold on;
    % p1.LineWidth = 1.5;
subplot(212)
    p2=plot(t_x_up, x_up, '.-b');
    % p2=plot(t_y_audio, y_demod, 'r');
    title('Sinal Transmitido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    xlim([0 t_x_up(end)])
    grid on;
%     p2.LineWidth = 1.5;
%%
% figure('Name', 'Sinal Elétrico', 'Position', [img_ph img_pv img_w img_h])
% plot(t_y_audio(1:.16*Fs_audio+1),y_audio(17.04*Fs_audio:17.2*Fs_audio),'r');
%     % title('Sinal Elétrico Recebido')
%     ylabel('Amplitude')
%     xlabel('Tempo [s]')
%     % ylim([-0.2 1.2])
%     % xlim([0 T_x*1.1])
%     axis tight
%     grid on;

%%
figure('Name', 'Sinal Elétrico', 'Position', [img_ph img_pv img_w img_h])
plot(t_y_audio,y_audio,'r');
    % title('Sinal Elétrico Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    % xlim([0 T_x*1.1])
    axis tight;
    ylim([-1.1 1.1])
    grid on;

%%
figure('Name', 'Sinal Recebido', 'Position', [img_ph img_pv img_w img_h])
plot(t_y_info, y_info, '*-r');
    % title('Sinal de Informação Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    xlim([0 t_y_info(end)])
    grid on; hold on;

%%
figure('Name', 'Comparação', 'Position', [img_ph img_pv img_w img_h])
subplot(211)
plot(t_x_info, x_info, '*-b');
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    xlim([0 t_x_info(end)])
    grid on; hold on;
subplot(212)
plot(t_y_info, y_info, '*-r');
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    xlim([0 t_y_info(end)])
    grid on; hold on;
%%
figure('Name', 'Sinal Transm vs Elétrico', 'Position', [img_ph img_pv img_w img_h])
subplot(121)
    p1=plot(t_x_up, x_up, '.-b');
    title('(a)', 'Units', 'normalized', 'Position', [0.5, -0.135, 0])
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    xlim([0 t_x_info(end)])
    grid on; hold on;
    % p1.LineWidth = 1.5;
    subplot(122)
    plot(t_y_audio,y_audio,'r');
    title('(b)', 'Units', 'normalized', 'Position', [0.5, -0.1, 0])
    % p2=plot(t_y_audio, y_demod, 'r');
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    % ylim([-0.2 1.2])
    xlim([0 t_x_up(end)])
    grid on;

%%
%%
figure('Name', 'Comparação', 'Position', [img_ph img_pv img_w img_h])
    p1=plot(t_x_info, x_info, '*--b');
    hold on;
    p2=plot(t_y_info, y_info, 'x-.r');
%     title('Sinal de Informação Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt*1.1])
    grid on; hold off;
    legend('Sinal de Informação Original','Sinal de Informação Recebido','Location','southeast')
    p1.LineWidth = 1.5;
    p2.LineWidth = 1.2;
%%
figure('Name', 'Comparação', 'Position', [img_ph img_pv img_w img_h])
    p1=plot(t_x_up, x_up, '*--b');
    hold on;
    p2=plot(t_y_up, y_up, 'x-.r');
%     title('Sinal de Informação Recebido')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    xlim([0 t_x_up(end)])
    grid on; hold off;
    legend('Sinal de Informação Original','Sinal de Informação Recebido','Location','southeast')
    p1.LineWidth = 1.5;
    p2.LineWidth = 1.2;