clc
clear
% 数据集名称
DataSets = {'wdbc', 'sonar', 'musk1', 'LSVT_voice_rehabilitation', 'colon', 'SRBCT', 'lung', 'lymphoma', 'ORL', 'lung_discrete'};

% 确保输出文件夹存在
outputFolder = 'output';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% 遍历每个数据集
for d = 1:length(DataSets)
    DataSet = DataSets{d};
    
    % 加载数据集
    load(['../data/', DataSet, '.mat']);
    X = data(:, 2:end);
    Y = data(:, 1);
    
    % 获取过滤后的特征索引
    [retained_features, retained_features_index, retain_feature_scores] = select_features_using_mic(X, Y);
    
    % 获取所有符合条件的文件（分别获取7-22和7-23日期的文件）
    filePattern1 = ['TSMMOPSO-FI_multimodal', DataSet, '_2024-07-22_*.txt'];
    filePattern2 = ['TSMMOPSO-FI_multimodal', DataSet, '_2024-07-23_*.txt'];
    files1 = dir(filePattern1);
    files2 = dir(filePattern2);
    
    % 合并文件列表
    files = [files1; files2];
    
    % 过滤出不包含 "Mapped" 或 "Sorted" 的文件
    files = files(arrayfun(@(f) ~contains(f.name, 'Mapped') && ~contains(f.name, 'Sorted'), files));
    

    % 初始化存储所有映射后的数据
    all_mapped_data = [];
    
    % 遍历每一个符合条件的文件
    for k = 1:length(files)
        baseFileName = files(k).name;
        fullFileName = fullfile(files(k).folder, baseFileName);
        
        % 读取txt文件内容
        fileID = fopen(fullFileName, 'r');
        data = textscan(fileID, '%s', 'Delimiter', '\n');
        fclose(fileID);
        
        % 遍历每一行，映射特征索引并转换错误率为正确率
        for i = 1:length(data{1})
            line = data{1}{i};
            fields = strsplit(line, ',');
            
            % 提取错误率并转换为正确率
            error_rate = str2double(fields{1});
            accuracy = 1 - error_rate;
            fields{1} = num2str(accuracy);
            
            % 提取特征索引并转换为数值数组
            feature_indices = str2num(char(fields(3:end))); %#ok<ST2NM>
            
            % 映射特征索引
            mapped_indices = map_to_original_indices(retained_features_index, feature_indices);
            
            % 将映射后的索引转换为带有 "F" 前缀的字符串数组
            mapped_indices_str = strcat('F', arrayfun(@num2str, mapped_indices, 'UniformOutput', false));
            
            % 重新组合成一行
            mapped_line = strjoin([fields(1:2), mapped_indices_str], ',');
            
            % 存储映射后的行和准确率
            all_mapped_data = [all_mapped_data; {accuracy, mapped_line}]; %#ok<AGROW>
        end
    end
    
    % 转换为表格并按准确率排序
    all_mapped_table = cell2table(all_mapped_data, 'VariableNames', {'Accuracy', 'Line'});
    sorted_table = sortrows(all_mapped_table, 'Accuracy');
    
    % 提取排序后的行
    sorted_lines = sorted_table.Line;
    
    % 将所有映射后的数据写回一个整体的txt文件
    newFileName = fullfile(outputFolder, ['zhongwen_multimodal', DataSet, '_2024-07-22_and_23_Mapped_Sorted.txt']);
    fileID = fopen(newFileName, 'w');
    if fileID == -1
        error('无法创建或打开文件: %s', newFileName);
    end
    for i = 1:length(sorted_lines)
        fprintf(fileID, '%s\n', sorted_lines{i});
    end
    fclose(fileID);
    
    disp(['处理完成，并写入到 ', newFileName]);
end

    function mapped_indices = map_to_original_indices(filtered_features, selected_indices)
        mapped_indices = filtered_features(selected_indices);
    end
    
