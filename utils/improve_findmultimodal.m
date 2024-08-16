function [multimodalset]= improve_findmultimodal(sortedpop)
%% 找到变更的下标
% num_cost=size(pf,2);
ps=sortedpop(:,1:end-2);
pf=sortedpop(:,end-1:end);
num_sample=size(ps,1);
first_idx=pf(1,:); 
idx=[1,]; 
% pf(:,1) = round(pf(:,1), 4);
for n =1:size(pf,1)  
  
   if isequal(first_idx,pf(n,:))    
     continue
   else
     idx=[idx n];   %找到发生变化的idx
     first_idx=pf(n,:);
   end
end
%% 根据下标阶段找不同的ps
p=1;
firstidx = idx; %每段相同的for循环起始位置
endidx=idx-1;
endidx=[endidx num_sample]; %每段相同的for循环终点位置
endidx = endidx(endidx~=0);

num_size_divide = size(firstidx,2); %一共有num_size_divide个相同的pf部分
fprintf("一共有%d个相同cost的部分\n",num_size_divide);
%% 寻找多模态解 
archive.cost=0;
archive.select_feat_idx=0;
multimodalset=[];
while p<=num_size_divide
  if (endidx(p)-firstidx(p))>=1     %差值大于等于1则说明pf有至少两个相同
    A=sortedpop(firstidx(p):endidx(p),:);   %取出这组相同的矩阵
    uniqueA=unique(A,'rows');  %按行去重
    if size(uniqueA,1)~=1  %如果去重后的行数不等于1，则说明找到多模态解
      fprintf("第 %d 个部分有多模态解\n",p);
       archives=repmat(archive,size(uniqueA,1),1);   %按找到的数量进行结构体的创建
       for i=1:size(unique(A,'rows'))  %赋值将cost和多模态解放入到archives中
         archives(i).cost=uniqueA(i,end-1:end);
         archives(i).select_feat_idx=find(uniqueA(i,:)==1);
       end
       multimodalset=[multimodalset;archives];
    end
  else     
  end
p=p+1;
end


