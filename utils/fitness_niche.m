function [fit] = fitness_niche(X_all,Y,position,threshold)
   position=position>threshold;
    num_feature = sum(position);  % num of selected feature
    if num_feature == 0
        fit = [1, 1];
        return;
    end
    num_feature=sum(position);  %选择的特征数
    nFeature=size(position,2);
         errorrate=KNNfitness(X_all(:,position==1),Y);

    featrate = num_feature/nFeature ;
    fit=[errorrate,featrate];
end

function error = KNNfitness(feat,label)
     mdl = fitcknn(feat,label,'Distance','euclidean',...
        'NumNeighbors',5,'KFold',5,'Standardize',1);
error = kfoldLoss(mdl);
 end


function error = Tree(feat,label)
        tree= fitctree(feat,label);
        cv = crossval(tree, 'KFold', 5);
        error = kfoldLoss(cv,'LossFun','classiferror');
end


