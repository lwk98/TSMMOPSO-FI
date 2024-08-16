function [fit] = fitness_niche2(X_all, Y, position, threshold, original_feature_count)
    position = position > threshold;
    num_feature = sum(position);  % 选择的特征数

    if num_feature == 0
        fit = [1, 1];
        return;
    end
    
    errorrate = KNNfitness(X_all(:, position), Y);
    featrate = num_feature / original_feature_count;  % 使用原始特征数量来计算特征比例

    fit = [errorrate, featrate];
end

function error = KNNfitness(feat,label)
     mdl = fitcknn(feat,label,'Distance','euclidean',...
        'NumNeighbors',5,'KFold',5,'Standardize',1);
error = kfoldLoss(mdl);
 end
