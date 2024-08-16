function sortedpop = sortpop(ps,pf,num_feature,n_obj,threshold)
         pf=round(pf,4);
         pop=[ps,pf];
         sorted_pop=sortrows(pop,num_feature+1:num_feature+n_obj,'ascend'); %pop按cost升序排序
         x=sorted_pop(:,1:end-2);
         x=x>threshold;
         y=sorted_pop(:,end-1:end);
         sortedpop=[x y];
end

