clear
clc
% 主文件夹路径
root_path = 'C:\Users\ll\Desktop\程序代码\multimodal个人实验代码\';  
addpath('C:\Users\ll\Desktop\程序代码\multimodal个人实验代码\utils');
addpath('C:\Users\ll\Desktop\程序代码\multimodal个人实验代码\result2');
addpath 'C:\Users\ll\Desktop\程序代码\minepy-master\minepy-master\matlab'

% 数据集名称列表
warning off
DataSets = {'wdbc','sonar', 'musk1', 'LSVT_voice_rehabilitation', 'colon', 'SRBCT', 'lung', 'lymphoma','ORL','Lung_discrete'};  % 可以添加更多数据集 'wdbc', 'sonar', 'musk1', 'LSVT_voice_rehabilitation', 'colon', 'SRBCT', 'lung', 'lymphoma'

% 算法名称列表
Algorithms = {'TSMMOPSO-FI'};  %  {'MMO_DE_CSCD', 'MO_Ring_PSO_SCD_FS', 'DN_NSGAII', 'OmniOptimizer', 'SSMOPSO_FS'}

% 突变概率
mutation_prob = 0.8;  % 设置突变概率

% 循环遍历所有算法
for algo_idx = 1:length(Algorithms)
    Algorithm = Algorithms{algo_idx};
    
    % 动态添加算法路径
    algo_path = fullfile(root_path, Algorithm);
    if exist(algo_path, 'dir')
        addpath(algo_path);  
    else
        warning('Algorithm path does not exist. Skipping...');
        continue;
    end
    
    % 循环遍历所有数据集
    for ds_idx = 1:length(DataSets)
        DataSet = DataSets{ds_idx};
        
        % 生成带有突变概率的日志文件名
        diary(['log_' Algorithm '_mutation_' num2str(mutation_prob) '.txt']);
        
        % 生成带有突变概率的结果文件名前缀
        result_file_prefix = {'train_acc', 'test_acc', 'numfeature', 'time', 'trainhv', 'testhv', 'trainIGD'};
        final_mean_prefix = {'ave_trainacc', 'ave_testacc', 'ave_featuresize', 'std_testacc', 'ave_trainhv', 'ave_testhv', 'std_trainacc', 'meantime(s)', 'std_trainhv', 'std_testhv'};
        
        % 获取当前时间字符串
        timeStr = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
        
        % 生成带有突变概率的结果文件名
        result_file = [Algorithm '_result_members_' DataSet '_mutation_' num2str(mutation_prob) '_' timeStr '.xls'];
        final_mean_std_output = [Algorithm '_final_' DataSet '_mutation_' num2str(mutation_prob) '_' timeStr '.xls'];
        MultimodalSet = [Algorithm '_multimodal_' DataSet '_mutation_' num2str(mutation_prob) '_' timeStr '.txt'];
        traincost_testcost_output = [Algorithm '_rep&testcost_' DataSet '_mutation_' num2str(mutation_prob) '_' timeStr '.xls'];
        
      result_members_all = [];
      Final.mean_train_acc = 0;
      Final.mean_test_acc = 0;
      Final.mean_feature_size = 0;
      Final.std_test_acc = 0;
      Final.mean_trainhv = 0;
      Final.mean_testhv = 0;
      Final.std_train_acc = 0;
      Final.std_test_acc = 0;
      Final.meantime = 0;
      Maxgeneration=50;
      n_pop=50;
      threshold=0.5;
      writecell(result_file_prefix,result_file);
      writecell(final_mean_prefix,final_mean_std_output);
        % 从这里开始，您可以加载数据集，初始化变量等。
        load(['../data/', DataSet,'.mat']);
        X = data(:, 2:end);
        Y = data(:, 1);
     original_feature_count = size(X, 2);
     % 执行特征选择
% 更新特征集
    if strcmp(Algorithm, 'TSMMOPSO-FI')
        [retained_features, retained_features_index,retain_feature_scores] = select_features_using_mic(X, Y);
        % 更新特征集
        X = retained_features;
        % 获取保留特征数量
        retained_feature_count = size(retained_features, 2);
   end
        n_var=size(X,2);
        n_obj=2;
        xl=zeros(1,size(X,2));
        xu=ones(1,size(X,2));
        num_feature = size(X, 2);
        num_samples = size(X,1);
        X_norm = (X - repmat(min(X), size(X, 1), 1)) ./ repmat(max(X) - min(X), size(X, 1), 1);  %标准化
        round=5;
        member.train_acc = 0; 
        member.test_acc = 0; 
        member.n_feature = 0;
        member.Algorithmtime = 0; 
        member.trainhv = 0;
        member.testhv = 0;
        result_members = repmat(member, round, 1); 
    for i=1:round
         [train_indices,valInd,test_indices] = dividerand(num_samples,0.7,0,0.3);
         X_train=X_norm(train_indices,:);Y_train=Y(train_indices);X_test=X_norm(test_indices,:);Y_test=Y(test_indices);
        % 根据算法名称调用相应的函数
        if strcmp(Algorithm, 'OmniOptimizer')
          start_time = clock; %一折的时间
          [oldps,oldpf] = Omni_Opt(X_train, Y_train,xl,xu,n_obj,n_var,n_pop,threshold,Maxgeneration);
          end_time = clock;
        elseif strcmp(Algorithm, 'DN_NSGAII')
          start_time = clock; 
          [oldps,oldpf] = DN_NSGAII(X_train, Y_train,xl,xu,n_obj,n_pop,threshold,Maxgeneration);
          end_time = clock; 
        elseif strcmp(Algorithm, 'TSMMOPSO-FI')
          start_time = clock; 
          [oldps,oldpf] = MIC_LocalMOPSO1(X_train, Y_train,n_obj,n_var,n_pop,threshold,Maxgeneration,retain_feature_scores,original_feature_count,mutation_prob);
          end_time = clock; 
        elseif strcmp(Algorithm, 'SSMOPSO_FS')
          start_time = clock; 
          [oldps,oldpf] = SSMOPSO(X_train, Y_train,xl,xu,n_obj,n_pop,threshold);
          end_time = clock; 
        elseif strcmp(Algorithm, 'MO_Ring_PSO_SCD_FS')
          start_time = clock; 
          [oldps,oldpf] =MO_Ring_PSO_SCD(X_train, Y_train,xl,xu,n_obj,n_pop,threshold);
          end_time = clock;
        elseif strcmp(Algorithm,'MMO_DE_CSCD')
          start_time = clock; 
          [oldps,oldpf] =MMO_DE_CSCD(X_train, Y_train,xl,xu,n_obj,n_pop,Maxgeneration,threshold);
          end_time = clock; 
        elseif strcmp(Algorithm,'PSNSGA')
          start_time=clock;
          [oldps,oldpf]=nsga(X_train, Y_train,n_var,n_pop,Maxgeneration);
          end_time=clock;
        elseif strcmp(Algorithm,'SPEA2')
          start_time=clock;
           [oldps,oldpf]= SPEA2(X_train, Y_train,xl,xu,n_obj,n_pop,threshold,Maxgeneration);
           end_time=clock;
        end
        particles=[oldps,oldpf];
        nsscd=non_domination_scd_sort(particles(:,1:n_var+n_obj),n_obj,n_var);
        tempindex=find(nsscd(:,n_var+n_obj+1)==1);
        ps=nsscd(tempindex,1:n_var);
        pf=nsscd(tempindex,n_var+1:n_var+n_obj);
        pop=sortpop(ps,pf,num_feature,n_obj,threshold);
        [MultimodalArchive] = improve_findmultimodal(pop);  %一个结构体archives返回多模态解
        if size(MultimodalArchive,1)>0
          writecell(struct2cell(MultimodalArchive)',MultimodalSet,'WriteMode','append');
        end
        unique_pop=unique(pop,'rows','stable');
        testcost = Cal_TestSet_Cost2(unique_pop,X_test,Y_test,threshold,original_feature_count);%不是结构体，是numrep行2列的矩阵测试集的pf
        traincost = unique(cat(1,unique_pop(:,end-1:end)),'rows','stable');
        train_error = sum(unique_pop(:,end-1))/size(unique_pop,1);
        FeatNumRate = sum(unique_pop(:,end))/size(unique_pop,1);
        test_error = sum(testcost(:,1))/size(testcost,1);
        writematrix(traincost',traincost_testcost_output,'WriteMode','append');
        writematrix(testcost',traincost_testcost_output,'Sheet',2,'WriteMode','append');
        trainpf = cat(1,pf);
        train_hv = Hypervolume_calculation(trainpf, [1,1]);%HV计算
        test_hv = Hypervolume_calculation(testcost,[1,1]);
        result_members(i).train_acc = 1-train_error;
        result_members(i).test_acc =  1-test_error;
        result_members(i).n_feature = FeatNumRate*original_feature_count;
        result_members(i).Algorithmtime = etime(end_time,start_time);
        result_members(i).trainhv = train_hv;   %训练集的HV
        result_members(i).testhv = test_hv;
        % 记录格式
        prefix = strcat('round', num2str(i), '/',num2str(round));
        logger([prefix, ' time:', num2str(result_members(i).Algorithmtime), 's',...
          ' train_acc:', num2str(result_members(i).train_acc), ...
          ' test_acc:', num2str(result_members(i).test_acc), ...
          ' featuresize:', num2str(result_members(i).n_feature),...
          'TrainHV:',num2str(result_members(i).trainhv),...
          'TestHV:',num2str(result_members(i).testhv)
          ]);
        % 后处理，例如结果存储、可视化等
    end
     writematrix(cell2mat(struct2cell(result_members))',result_file,'WriteMode','append');
            % 计算 Final 结构体的值
         result_members_all = [result_members_all; result_members];
         Final.meantime = mean([result_members_all.Algorithmtime]);
         Final.mean_train_acc = mean([result_members_all.train_acc]);
         Final.std_train_acc = std([result_members_all.train_acc]);
         Final.mean_test_acc = mean([result_members_all.test_acc]);
         Final.std_test_acc = std([result_members_all.test_acc]);
         Final.mean_feature_size = mean([result_members_all.n_feature]);
         Final.mean_trainhv = mean([result_members_all.trainhv]);
         Final.std_trainhv = std([result_members_all.trainhv]);
         Final.mean_testhv = mean([result_members_all.testhv]);
         Final.std_testhv = std([result_members_all.testhv]);
         logger(['Dataset:',DataSet]);
         logger(['Algorithm:',Algorithm]);
         logger(['average training accuracy = ', num2str(Final.mean_train_acc) '±' num2str(Final.std_train_acc)]);
         logger(['average testing accuracy = ', num2str(Final.mean_test_acc) '±' num2str(Final.std_test_acc)]);
         logger(['std testing accuracy = ', num2str(Final.std_test_acc)]);
         logger(['average feature size = ', num2str(Final.mean_feature_size)]);
         logger(['average trainhv = ', num2str(Final.mean_trainhv) '±' num2str(Final.std_trainhv)]);
         logger(['average testhv = ', num2str(Final.mean_testhv) '±' num2str(Final.std_trainhv)]);
         writematrix(cell2mat(struct2cell(Final))',final_mean_std_output,'WriteMode','append');
    end

end
