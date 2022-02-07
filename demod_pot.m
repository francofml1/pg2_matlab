% clear all; close all;
% load('dados/n-35_Tb-0.1.mat')
%%

% módulo:
y_abs = abs(y_ruido);

% ty = 0:Tb:t_yr(end)+1;
ty = t_x;
y = zeros(size(ty));

soma = [];
aux = find(y_abs > 0.05);
if aux
    idx_ti = aux(1);
else
    idx_ti = 1;
end
% t_yr = t_yr - t_yr(idx_ti);
% idx_ti = 1;

for i = 1:length(ty)-1;
    tib = t_yr(idx_ti);
    tfb = tib + Tb;
    aux = find(t_yr >= tfb);
    if length(aux)
        idx_tf = aux(1) - 1;
    else
        idx_tf = length(t_yr);
    end

    soma(i) = sum(y_abs(idx_ti:idx_tf));
    if soma(i) > 20
        y(i) = 1;
    end

    % tfb = tib + Tb*.8;
    % aux = find(t_yr >= tfb);
    % if length(aux)
    %     idx_tf = aux(1) - 1;
    % else
    %     idx_tf = length(t_yr);
    % end
    idx_ti = idx_tf;
end

figure()
    plot(soma, '*-')

figure('Name', 'Tratado Downsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(ty, y,'*-r'); 
    grid on;
    title('Sinal Tratado')
    ylabel('Amplitude')
    xlabel('Tempo [ms]')
    ylim([-0.2 1.2])
    % xlim([0 Tt])
