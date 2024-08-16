function mutated_particle = mutateSeedParticle(seed_particle, mutation_prob, feature_importance, n_var, X_train,Y_train,threshold,orgin_feature)
    % seed_particle: 当前的种子粒子
    % mutation_prob: 突变概率
    % feature_importance: 特征的重要性数组
    n_obj=2;
    mutated_particle = seed_particle; % 初始化突变粒子
    for i = 1:n_var
        if seed_particle(i) > 0 && rand() < mutation_prob * (1 - feature_importance(i))
            mutated_particle(i) = 0.5*rand(); % 删除特征（设置为0）
        end
    end

    for i = 1:n_var
        if seed_particle(i) == 0 && rand() < mutation_prob * feature_importance(i)
            mutated_particle(i) = 0.5+0.5*rand(); % 选中特征，赋予随机值
        end
    end

    % 计算原始粒子和突变粒子的适应度
    mutated_particle(1,n_var+1:n_var+n_obj)=fitness_niche2(X_train,Y_train,mutated_particle(1,1:n_var),threshold,orgin_feature);

    % 比较适应度并选择输出粒子
    if dominates(mutated_particle(1,n_var+1:n_var+n_obj), seed_particle(1,n_var+1:n_var+n_obj))
        % 如果突变粒子支配原始粒子，则输出突变粒子
        return
    elseif dominates(seed_particle(1,n_var+1:n_var+n_obj),mutated_particle(1,n_var+1:n_var+n_obj))
        % 如果原始粒子支配突变粒子，则输出原始粒子
        mutated_particle = seed_particle;
    else
        % 如果两者互不支配，以50%的概率选择输出其中一个
        if rand() < 0.5
            mutated_particle = seed_particle;
        end
    end
end

function is_dominating = dominates(fitness1, fitness2)
    is_dominating = all(fitness1 <= fitness2) && any(fitness1 < fitness2);
end


