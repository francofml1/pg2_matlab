% clear all; close all;
% load('dados/n-35_Tb-0.1.mat')
%%

% módulo:
y_abs = abs(y_ruido);

% ty_s = 0:Tb/2:t_yr(end);
% ty = 0:Tb:t_yr(end);
ty_s = 0:Tb/(nsamp*2):t_x(end);
t_yup = t_xup;
yup_s = zeros(size(ty_s));
y_up = zeros(size(t_yup));

soma = [];
aux = find(y_abs > 0.05);
if aux
    idx_ti = aux(1);
else
    idx_ti = 1;
end
% idx_ti = 1;

iy = 1;
for i = 1:length(ty_s)-1;
    tib = t_yr(idx_ti);
    tfb = tib + Tb/2;
    aux = find(t_yr >= tfb);
    if length(aux)
        idx_tf = aux(1) - 1;
    else
        idx_tf = length(t_yr);
    end

    soma(i) = sum(y_abs(idx_ti:idx_tf));
    if soma(i) > 20
        yup_s(i) = 1;
    end


    if not(bitand(i, 1))
        % disp('i= ' + string(i));
        % disp('iy= ' + string(iy));
        if not((yup_s(i) == 0) && (yup_s(i-1) == 0))
            y_up(iy) = 1;
        end
        iy = iy + 1;
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

% Reamostragem (downsample)
y = intdump(y_up,nsamp);
t_y = 0:Tb:(length(y)-1)*Tb;

% soma2 = [];
% js=1
% for j = 1:2:length(yup_s)-1
%     soma2(js) = yup_s(j) + yup_s(j+1);
%     js = js + 1;
% end
% figure()
%     plot(soma2, '*-')
%     grid on;

% figure('Name', 'Somatórios de Amplitude', 'Position', [img_ph img_pv img_w img_h])
%     plot(soma, '*-')
%     grid on;
%     title('Somatórios de Amplitude')
%     ylabel('Amplitude')
%     xlabel('Tempo [s]')
    
figure('Name', 'Tratado Soma', 'Position', [img_ph img_pv img_w img_h])
    plot(ty_s, yup_s,'*-r'); 
    grid on;
    title('Sinal Tratado Soma')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt])
    
figure('Name', 'Tratado UPsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(t_yup, y_up,'*-r'); 
    grid on;
    title('Sinal Tratado UPsampled')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt])
