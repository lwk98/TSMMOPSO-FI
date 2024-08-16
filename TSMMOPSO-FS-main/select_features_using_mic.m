function [retained_features, retained_features_index, retained_feature_scores] = select_features_using_mic(features, categories)
    % 计算特征与类别之间的MIC值
    function mic = calculate_feature_class_mic(X, Y)
        MIC_values = zeros(1, size(X, 2)); 
        for i = 1:size(X, 2)
            result = mine(X(:, i)', Y');
            MIC_values(i) = result.mic;
        end
        mic = MIC_values;
    end

    % 使用Spearman相关系数计算特征间的冗余性
    function redundancy_matrix = calculate_feature_redundancy(X)
        redundancy_matrix = corr(X, 'Type', 'Spearman');
    end

    % 计算特征与类别之间的MIC值
    feature_class_mic = calculate_feature_class_mic(features, categories);

    % 计算特征间的冗余性
    feature_redundancy = calculate_feature_redundancy(features);
    average_feature_redundancy = mean(abs(feature_redundancy), 2);

    % 归一化MIC值和冗余值
    norm_feature_class_mic = (feature_class_mic - min(feature_class_mic)) / (max(feature_class_mic) - min(feature_class_mic));
    norm_average_feature_redundancy = (average_feature_redundancy - min(average_feature_redundancy)) / (max(average_feature_redundancy) - min(average_feature_redundancy));

    % 计算加权平均得分
    weight_for_class = 0.5;
    weight_for_feature = 1 - weight_for_class;
    overall_scores = weight_for_class * norm_feature_class_mic + weight_for_feature *(1- norm_average_feature_redundancy)';

    % 根据特征数量调整保留特征的阈值百分位
    original_feature_count = size(features, 2);
    if original_feature_count <= 100
        percentile_value = 40;  
    elseif original_feature_count > 100 && original_feature_count <= 500
        percentile_value = 60;  
    else
        percentile_value = 85;  
    end
    threshold = prctile(overall_scores, percentile_value);

    % 确定高于或等于阈值的特征索引
    retained_features_index = find(overall_scores >= threshold);

    % 提取保留的特征
    retained_features = features(:, retained_features_index);

    % 提取保留的特征的得分
    retained_feature_scores = overall_scores(retained_features_index);
end
