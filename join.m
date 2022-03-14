list = dir('.\dados\2022*');

for iii = 1:length(list)
    item_mat = list(iii);
    load(strcat(item_mat.folder, '\', item_mat.name));
    graph_enable = 1;


    options = struct( ...
        'format', 'html', ...
        'outputDir', strcat('.\published2\', item_mat.name)...
    );
    publish('graficos.m', options)
    close all;

end % for item = list
