list = dir('.\dados\2022*');

ar_Tb_x_up = [];
ar_n_err = [];
ar_ber = [];
ar_ber_est = [];
ar_Fs_x_up = [];

tb_left = 0;
aaa = 1;
for iii = 1:length(list)
    item_mat = list(iii);
    load(strcat(item_mat.folder, '\', item_mat.name));
    % graph_enable = 1;

    if (tb_left ~= Tb_x_up)

        ar_Tb_x_up(aaa) = Tb_x_up;
        ar_n_err(aaa) = n_err;
        ar_ber(aaa) = ber;
        ar_ber_est(aaa) = ber_est;
        ar_Fs_x_up(aaa) = Fs_x_up;


        aaa = aaa + 1;
        tb_left = Tb_x_up
    end

    % options = struct( ...
    %     'format', 'html', ...
    %     'outputDir', strcat('.\published2\', item_mat.name)...
    % );
    % publish('graficos.m', options)
    % close all;

end % for item = list
save('ber5.mat')