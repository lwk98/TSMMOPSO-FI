function f = non_domination_sort_crowd_dist(x, M, V)

%% function f = non_domination_sort_crowd_dist(x, M, V)
% x     粒子
% M     目标空间维度
% N     决策空间维度

% f     按照非支配排序从前到后，拥挤距离从大到小排序后的种群
%%
[N, m] = size(x);
clear m

% Initialize the front number to 1.
front = 1;

% There is nothing to this assignment, used only to manipulate easily in
% MATLAB.
F(front).f = [];
individual = [];

%% Non-Dominated sort. 

for i = 1 : N
    % Number of individuals that dominate this individual
    individual(i).n = 0; 
    % Individuals which this individual dominate
    individual(i).p = [];
    for j = 1 : N
        dom_less = 0;
        dom_equal = 0;
        dom_more = 0;
        for k = 1 : M
            if (x(i,V + k) < x(j,V + k))
                dom_less = dom_less + 1;
            elseif (x(i,V + k) == x(j,V + k))  
                dom_equal = dom_equal + 1;
            else
                dom_more = dom_more + 1;
            end
        end
        if dom_less == 0 && dom_equal ~= M
            individual(i).n = individual(i).n + 1;
        elseif dom_more == 0 && dom_equal ~= M
            individual(i).p = [individual(i).p j];
        end
    end   
    if individual(i).n == 0
        x(i,M + V + 1) = 1;
        F(front).f = [F(front).f i];
    end
end
% Find the subsequent fronts
while ~isempty(F(front).f)
   Q = [];
   for i = 1 : length(F(front).f)
       if ~isempty(individual(F(front).f(i)).p)
        	for j = 1 : length(individual(F(front).f(i)).p)
            	individual(individual(F(front).f(i)).p(j)).n = ...
                	individual(individual(F(front).f(i)).p(j)).n - 1;
        	   	if individual(individual(F(front).f(i)).p(j)).n == 0
               		x(individual(F(front).f(i)).p(j),M + V + 1) = ...
                        front + 1;
                    Q = [Q individual(F(front).f(i)).p(j)];
                end
            end
       end
   end
   front =  front + 1;
   F(front).f = Q;
end

[temp,index_of_fronts] = sort(x(:,M + V + 1));
for i = 1 : length(index_of_fronts)
    sorted_based_on_front(i,:) = x(index_of_fronts(i),:);
end
current_index = 0;

%% Crowding distance

for front = 1 : (length(F) - 1)
%    objective = [];
    crowd_dist_obj = 0;
    y = [];
    previous_index = current_index + 1;
    for i = 1 : length(F(front).f)
        y(i,:) = sorted_based_on_front(current_index + i,:);%取出第front前沿个体放入y中
    end
    current_index = current_index + i;
    % Sort each individual based on the objective
    sorted_based_on_objective = [];
    for i = 1 : M+V
        [sorted_based_on_objective, index_of_objectives] = ...
            sort(y(:,i));
        sorted_based_on_objective = [];
        for j = 1 : length(index_of_objectives)
            sorted_based_on_objective(j,:) = y(index_of_objectives(j),:);
        end
        f_max = ...
            sorted_based_on_objective(length(index_of_objectives), i);
        f_min = sorted_based_on_objective(1,  i);

        if length(index_of_objectives)==1
            y(index_of_objectives(1),M + V + 1 + i) = 1;%如果该前沿只有一个点
          
        elseif i>V
              %目标空间内每一维的边界点拥挤距离赋值为最大值或最小值（最小化问题低边界点赋最大值高边界点赋最小值，最大化问题颠倒）
            y(index_of_objectives(1),M + V + 1 + i) = 1;
            y(index_of_objectives(length(index_of_objectives)),M + V + 1 + i)=0;
        else
            %决策空间内每一维的边界点拥挤距离赋值为：边界点与邻居点距离的二倍
             y(index_of_objectives(length(index_of_objectives)),M + V + 1 + i)...
                = 2*(sorted_based_on_objective(length(index_of_objectives), i)-...
            sorted_based_on_objective(length(index_of_objectives) -1, i))/(f_max - f_min);
             y(index_of_objectives(1),M + V + 1 + i)=2*(sorted_based_on_objective(2, i)-...
            sorted_based_on_objective(1, i))/(f_max - f_min);
        end
         for j = 2 : length(index_of_objectives) - 1
            next_obj  = sorted_based_on_objective(j + 1, i);
            previous_obj  = sorted_based_on_objective(j - 1,i);
            if (f_max - f_min == 0)
                y(index_of_objectives(j),M + V + 1 + i) = 1;
            else
                y(index_of_objectives(j),M + V + 1 + i) = ...
                     (next_obj - previous_obj)/(f_max - f_min);
            end
         end
    end
    %Calculate distance in x space
    crowd_dist_var = [];
    crowd_dist_var(:,1) = zeros(length(F(front).f),1);
    for i = 1 : V
        crowd_dist_var(:,1) = crowd_dist_var(:,1) + y(:,M + V + 1 + i);
    end
    crowd_dist_var=crowd_dist_var./V;
    avg_crowd_dist_var=mean(crowd_dist_var);
    %Calculate distance in f space
    crowd_dist_obj = [];
    crowd_dist_obj(:,1) = zeros(length(F(front).f),1);
    for i = 1 : M
        crowd_dist_obj(:,1) = crowd_dist_obj(:,1) + y(:,M + V + 1+V + i);
    end
    crowd_dist_obj=crowd_dist_obj./M;
    avg_crowd_dist_obj=mean(crowd_dist_obj);
    crowd_dist=zeros(length(F(front).f),1);
    for i = 1 : length(F(front).f)
        if crowd_dist_obj(i)>avg_crowd_dist_obj||crowd_dist_var(i)>avg_crowd_dist_var
            crowd_dist(i)=max(crowd_dist_obj(i),crowd_dist_var(i));
        else
            crowd_dist(i)=min(crowd_dist_obj(i),crowd_dist_var(i));
        end
    end
    y(:,M + V + 2) = crowd_dist;
    y(:,M+V+3)=crowd_dist_var;
    y(:,M+V+4)=crowd_dist_obj;
    [~,index_sorted_based_crowddist]=sort(crowd_dist,'descend');%%同一非支配排序的再按照拥挤距离排序
    y=y(index_sorted_based_crowddist,:);
    y = y(:,1 : M + V+2 );
    z(previous_index:current_index,:) = y;
end
f = z();
end