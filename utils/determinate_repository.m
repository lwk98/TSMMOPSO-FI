function     [particle  Q]=determinate_repository(particle)


n=length(particle);

for i=1:n
   particle(i).isdominate=0; 
end


Q=[];

for i=1:n-1

    for j=i+1:n
        
        if domination(particle(i).cost,particle(j).cost)
            particle( j ).isdominate=1;                  %找到非支配解
        elseif domination(particle(j).cost,particle(i).cost)
            particle(i).isdominate=1;
        end
               
    end
    
    
    if particle(i).isdominate==0
        [Q]=[Q i];
    end
    
end
if particle(n).isdominate==0
        [Q]=[Q n];
end
                                    %返回非支配解的序号

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                   %
%                          www.matlabnet.ir                         %
%                   Free Download  matlab code and movie            %
%                          Shahab Poursafary                        %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%