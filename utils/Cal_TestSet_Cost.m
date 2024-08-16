function Crep = Cal_TestSet_Cost(particle,X_test,Y_test,threshold)
  
%particle由position和cost组成，是矩阵，不是结构体。
ps=particle(:,1:end-2);
paretocost=[];
    for i=1:size(particle,1)
        paretocost(i).cost=fitness_niche(X_test,Y_test,ps(i,:),threshold);
    end

    [ParetoParticle , Q]=determinate_repository(paretocost);
    
    testpareto=ParetoParticle(Q);
    
     Crep=cat(1,testpareto.cost);   %errorrate,featrate
     Crep=sortrows(Crep);

end

