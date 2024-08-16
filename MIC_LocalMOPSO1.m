function[ps,pf]= MIC_LocalMOPSO1(X_train, Y_train,n_obj,n_var,n_pop,threshold,Maxgeneration,feature_importance,orgin_feature,mutation_prob)
Particle_Number=n_pop;
n_PBA=20;
w=0.7298;
c1=2.05;
c2=2.05;
VRmax=ones(1,n_var);
VRmin=zeros(1,n_var);
mv=0.5*(VRmax-VRmin);
VRmin=repmat(VRmin,Particle_Number,1);
VRmax=repmat(VRmax,Particle_Number,1);
Vmin=repmat(-mv,Particle_Number,1);
Vmax=-Vmin;
pos = rand(Particle_Number, n_var); % 初始化位置
vel = rand(Particle_Number, n_var); % 初始化速度
fitness=zeros(Particle_Number,n_obj);
for i=1:Particle_Number
  fitness(i,:)=fitness_niche2(X_train,Y_train,pos(i,:),threshold,orgin_feature);
end
particle=[pos,fitness];
row_of_cell=ones(1,Particle_Number); % the number of row in each cell
col_of_cell=size(particle,2);        % the number of column in each cell
PBA=mat2cell(particle,row_of_cell,col_of_cell);% 把粒子的每行拆开，当作当前的粒子的最佳位置


for i=1:Maxgeneration
 niche_size = ceil(i / 10); 
nbest = cell(ceil(Particle_Number / niche_size), 1); % 初始化空的cell数组
nbestindex=cell(ceil(Particle_Number / niche_size), 1);
is_assigned = false(1, Particle_Number); % 标记粒子是否已分配
% 生成距离矩阵，假设particle是一个Particle_Number x n_var的矩阵
distance_matrix = pdist2(particle(:,1:end-2), particle(:,1:end-2));
cell_idx = 1;
while ~all(is_assigned)
    % 选择一个未分配的粒子作为种子
    unassigned_particles = particle(~is_assigned, 1:n_var + n_obj);
    
    % 对这些未分配的粒子进行非支配排序
    sorted_unassigned_particles = non_domination_scd_kmeans_sort(unassigned_particles(:,1:n_var+n_obj), n_obj, n_var,10);
    
    % 选择排序第一的粒子作为种子
    seed_particle = sorted_unassigned_particles(1, 1:n_var+n_obj);
    
    seed_idx = find(all(particle == seed_particle, 2));
    % 计算距离并排序
    distances = distance_matrix(seed_idx, :);
    [~, sorted_indices] = sort(distances,'descend');
    
    % 过滤已分配的粒子并选择最近的niche_size个粒子
    filtered_indices = sorted_indices(~is_assigned(sorted_indices));
    if length(filtered_indices) > niche_size
        neighbors = filtered_indices(1:niche_size);
    else
        neighbors = filtered_indices;
    end

% 将这些粒子的信息存储到nbest中
nsscd = non_domination_scd_sort(particle(neighbors, 1:n_var + n_obj), n_obj, n_var);
nbest{cell_idx} = nsscd;
nbestindex{cell_idx} = neighbors;
newseedparticle=mutateSeedParticle(nbest{1}(1,1:n_var+n_obj), mutation_prob, feature_importance,n_var,X_train,Y_train,threshold,orgin_feature);
% newseedparticle(1,n_var+1:n_var+n_obj)=fitness_niche2(X_train,Y_train,newseedparticle(1,1:n_var),threshold,orgin_feature);
% if domination(newseedparticle(1,n_var+1:n_var+n_obj),nbest{1}(1,n_var+1:n_var+n_obj))
nbest{1}(1,1:n_var+n_obj)=newseedparticle;
% end
% if newseedparticle(1,n_var+n_obj)<nbest{1}(1,n_var+n_obj)
%   nbest{1}(1,1:n_var+n_obj)=newseedparticle;
% end
for k=1:size(neighbors,2)
      PBA_k=PBA{neighbors(k),1};
      pbest=PBA_k(1,:);
      vel(neighbors(k), :) = w * vel(neighbors(k), :) ...
                              + c1 * rand(1, n_var) .* (pbest(1, 1:n_var) - particle(neighbors(k), 1:n_var)) ...
                              + c2 * rand(1, n_var) .* (nbest{cell_idx}(1,1:n_var) - particle(neighbors(k), 1:n_var));
    %% 限制速度 
      vel(neighbors(k), :)=( vel(neighbors(k), :)>mv).*mv+(vel(neighbors(k), :)<=mv).* vel(neighbors(k), :); 
             vel(neighbors(k), :)=( vel(neighbors(k), :)<(-mv)).*(-mv)+( vel(neighbors(k), :)>=(-mv)).* vel(neighbors(k), :);
        particle(neighbors(k),1:n_var)=vel(neighbors(k),:)+particle(neighbors(k),1:n_var);
 %% 限制位置
   particle(neighbors(k),1:n_var)=(( particle(neighbors(k),1:n_var)>=VRmin(1,:))&( particle(neighbors(k),1:n_var)<=VRmax(1,:))).* particle(neighbors(k),1:n_var)...
                +( particle(neighbors(k),1:n_var)<VRmin(1,:)).*(VRmin(1,:)+0.25.*(VRmax(1,:)-VRmin(1,:)).*rand(1,n_var))+( particle(neighbors(k),1:n_var)>VRmax(1,:)).*(VRmax(1,:)-0.25.*(VRmax(1,:)-VRmin(1,:)).*rand(1,n_var));

        particle(neighbors(k),n_var+1:n_var+n_obj)=fitness_niche2(X_train,Y_train,particle(neighbors(k),1:n_var),threshold,orgin_feature);
 %% 合并PBA


      PBA_k = [PBA_k(:, 1:n_var+n_obj); particle(neighbors(k),1:n_var+n_obj)];
        PBA_k = non_domination_scd_kmeans_sort(PBA_k(:,1:n_var+n_obj), n_obj, n_var,10);

% 设置阈值和特征数量范围
         if size(PBA_k,1)>n_PBA
          PBA{neighbors(k),1}=PBA_k(1:n_PBA,:);
        else
          PBA{neighbors(k),1}=PBA_k;
        end
end
    cell_idx = cell_idx + 1;
    
    % 标记这些粒子为已分配
    is_assigned(neighbors) = true;
 end

end
  tempEXA=cell2mat(PBA);                     
    tempEXA=non_domination_scd_kmeans_sort(tempEXA(:,1:n_var+n_obj), n_obj, n_var,10);
    if size(tempEXA,1)>Particle_Number
         EXA=tempEXA(1:Particle_Number,:);
     else
        EXA=tempEXA;
    end
   tempindex=find(EXA(:,n_var+n_obj+1)==1);% Find the index of the first rank particles
   ps=EXA(tempindex,1:n_var);  %代表决策空间的最优集合，其实就是特征选择里所选的特征。
   pf=EXA(tempindex,n_var+1:n_var+n_obj);%代表目标空间里的最优集合，就是特征选择里的cost
end

