% clear all; close all;
% load('dados/n-35_Tb-0.1.mat')
%%

% módulo:
y_abs = abs(y_ruido);

% tyup = 0:Tb/2:t_yr(end);
% ty = 0:Tb:t_yr(end);
tyup = 0:Tb/2:t_x(end);
ty = t_x;
yup = zeros(size(tyup));
y = zeros(size(ty));

soma = [];
aux = find(y_abs > 0.05);
if aux
    idx_ti = aux(1);
else
    idx_ti = 1;
end
% idx_ti = 1;

iy = 1;
for i = 1:length(tyup)-1;
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
        yup(i) = 1;
    end


    if not(bitand(i, 1))
        % disp('i= ' + string(i));
        % disp('iy= ' + string(iy));
        if not((yup(i) == 0) && (yup(i-1) == 0))
            y(iy) = 1;
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

% soma2 = [];
% js=1
% for j = 1:2:length(yup)-1
%     soma2(js) = yup(j) + yup(j+1);
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
    
figure('Name', 'Tratado UPsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(tyup, yup,'*-r'); 
    grid on;
    title('Sinal Tratado UPsampled')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt])
    
figure('Name', 'Tratado Downsampled', 'Position', [img_ph img_pv img_w img_h])
    plot(ty, y,'*-r'); 
    grid on;
    title('Sinal Tratado')
    ylabel('Amplitude')
    xlabel('Tempo [s]')
    ylim([-0.2 1.2])
    % xlim([0 Tt])
