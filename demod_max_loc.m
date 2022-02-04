% clear all; close all;
% load('dados/n-35_Tb-0.1.mat')
%%

% m?dulo:
y_abs = abs(y_ruido);

%% Encontra picos:
[pks,locs] = findpeaks(y_abs,t_yr,'MinPeakDistance',Tb*.5,'MinPeakHeight',.1);

% figure('Name', 'Identifica??o dos Picos', 'Position', [img_ph img_pv img_w img_h])
% findpeaks(y_abs,t_yr,'MinPeakDistance',Tb/2,'MinPeakHeight',.1);
% text(locs+.01,pks,num2str((1:numel(pks))'));

t_yup = t_yr -  locs(1);
locs_1 = locs - locs(1);

y_up = zeros(size(y_abs));
for index = 1:length(locs_1)
    y_up(find(t_yup == (locs_1(index)))) = 1;
end


y = zeros(size(x));
t_y = t_x;

% idx_tx = 1;
for t = locs_1
    idx_tx = find(t_x >= t);
    
    if length(idx_tx)
        idx_tx = idx_tx(1);
    else
        idx_tx = length(t_x)-1;
    end
    % disp('t = ' + string(t) + '; idx_tx = ' + string(idx_tx) + '; t_x(idx_tx) = ' + string(t_x(idx_tx)))
    y(idx_tx) = 1;
end


disp('1`s de x: ' + string(sum(x(:) == 1)))
disp('1`s de y_up: ' + string(sum(y_up(:) == 1)))
disp('1`s de y: ' + string(sum(y(:) == 1)))


% figure('Name', 'Sinal Original no Tempo', 'Position', [img_ph img_pv img_w img_h])
%     % subplot(211)
%     p1=plot(t_x, x, '*-b');
%     title('Sinal Original')
%     ylabel('Amplitude')
%     xlabel('Tempo [ms]')
%     ylim([-0.2 1.2])
%     xlim([0 Tt])
%     grid on; hold on;

figure('Name', 'Tratado upsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(t_yup, y_up,'*-r'); 
    grid on;
    title('Sinal Tratado upsampled')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.2 1.2])
    % xlim([0 Tt])

figure('Name', 'Tratado Downsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(t_y, y,'*-r'); 
    grid on;
    title('Sinal Tratado')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.2 1.2])
    % xlim([0 Tt])

