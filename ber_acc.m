list = dir('.\dados\2022*');

s = struct('Fs_x_up', [], 'Tb_x_up', [], 'n_err_acc', [], 'n_acc', [], 'ber_f', [], 'n_err_up_acc', [], 'n_up_acc', [], 'ber_up_f', [])

tb_left = 0;
aaa = 0;
for iii = 1:length(list)
    item_mat = list(iii);
    load(strcat(item_mat.folder, '\', item_mat.name));
    % graph_enable = 1;

    [n_err_up, ber_up] = biterr(x_up, y_up);


    if (tb_left ~= Tb_x_up)
        aaa = aaa + 1;

        s.Fs_x_up(aaa) = Fs_x_up;
        s.Tb_x_up(aaa) = Tb_x_up;

        s.n_err_acc(aaa) = n_err;
        s.n_acc(aaa) = n;
        s.ber_f = ber;

        s.n_err_up_acc(aaa) = n_err_up;
        s.n_up_acc(aaa) = length(y_up);
        s.ber_up_f = ber_up;

        tb_left = Tb_x_up
    else
        s.n_err_acc(aaa) = s.n_err_acc(aaa) + n_err;
        s.n_acc(aaa) = s.n_acc(aaa) + n;

        s.n_err_up_acc(aaa) = s.n_err_up_acc(aaa) + n_err_up;
        s.n_up_acc(aaa) = s.n_up_acc(aaa) + length(y_up);
    end

end % for item = list

s.ber = 100 * s.n_err_acc ./ s.n_acc;
s.ber_up = 100 * s.n_err_up_acc ./ s.n_up_acc;

cftool(s.Fs_x_up,s.ber);
cftool(s.Fs_x_up,s.ber_up);