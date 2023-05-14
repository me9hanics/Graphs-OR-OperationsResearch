function [circ_new,tau] = min_mean_cycle_0demand(from,ends,capacities,costs,circ_current)
%Assuming that dirG is a digraph(), that consists of list of edge starting nodes, list of edge ending nodes, and list of capacities 

%Circulation has demand function g=0 for simpilicty
demands=0;

%Create the residual graph
forward_from=[];
forward_ends=[];
forward_capacities=[];
forward_costs=[];
reverse_from=[];
reverse_ends=[];
reverse_capacities=[];
reverse_costs=[];
for i = 1:size(circ_currect,2) %loop through the circulation
   if(circ_current(1,i)<capacities(1,i))
        forward_from = [forward_from from(1,i)];
        forward_ends = [forward_ends ends(1,i)];
        forward_capacities = [forward_capacities ( capacities(1,i)-circ_current(1,i) )];
        forward_costs = [forward_costs costs(1,i)];
   end
   
   if(circ_current(1,i)>demands)
        reverse_from = [reverse_from ends(1,i)];
        reverse_ends = [reverse_ends from(1,i)];
        reverse_capacities = [reverse_capacities circ_current(1,i)];
        reverse_costs = [reverse_costs costs(1,i)*(-1)];
   end
end

res_from = [forward_from reverse_ends];
res_ends = [forward_ends reverse_from];
res_capacities = [forward_capacities reverse_capacities];
res_costs = [forward_costs reverse_costs];

resG = digraph(res_from, res_ends, res_capacities);
n=size(resG.Nodes,1);
m=size(resG.Edges,1);
resG.Nodes=(1:n)';
resG.Edges.Costs=res_costs;

%Creating an Nx(N+1) matrix for distances, filling it up with Inf values
distance_matrix = ones(size(resG.Nodes,1),size(resG.Nodes,1)+1)/0; 
distance_matrix(:,1)=0; %Fill up first column with 0 (d_0(u)=0)
settingedge_matrix = -ones(n)/0; %negative infinities

%Finding distances (similar to Bellman-Ford)
for k=1:n
    for j=1:m
        if(distance_matrix(res_from(1,j),k)+res_costs(1,j)<distance_matrix(res_ends,k+1))
            distance_matrix(res_ends,k+1)=distance_matrix(res_from(1,j),k)+res_costs(1,j);
            settingedge_matrix(res_ends(1,j),k)=j; %storing the edge that set it
        end
    end
end

%Find the minimum mean cycle
maxdiffs = -ones(1,n)/0;


for v=1:n
    for k=1:n
        if(((distance_matrix(v,n+1)-distance_matrix(v,k))/(n+1-k))>maxdiffs(1,v))
            maxdiffs(1,v)=(distance_matrix(v,n+1)-distance_matrix(v,k))/(n+1-k);
            
        end
    end
end
min_mean =  maxdiffs(1,1);
min_mean_vertex = resG.Nodes(1,1); %shall equal to '1'
for v=1:n
    if (min_mean>maxdiffs(1,v))
        min_mean=maxdiffs(1,v);
        min_mean_vertex=resG.Nodes(v,1); %shall equal to the value of 'v' in fact
    end
end


%If the minimum mean is less than 0, then we can improve on the cost, else
%we are finished
if(min_mean<0)
    %Find the minimum mean cycle
    %Store the vertices in dn(v)y
    settingwalk = 1:(n+1);
    for k = 1:n
        settingwalk(r) = res_from(settingedge_matrix(min_mean_vertex,k));
    end
    settingwalk(n+1) = res_ends(settingedge_matrix(min_mean_vertex,n+1));
    min_mean_cycle = 1:n;
    min_mean_cycle_end = n;
    for v = (2:n+1)
        for k = (1:v-1)
           if(settingwalk(k)==settingwalk(v))
               cycle = 0;
               for c = (k+1:v)
                   cycle = cycle + res_costs(settingedge_matrix(min_mean_vertex,c));
               end
               if(cycle == min_mean)
                   for c = (k+1:v)
                       min_mean_cycle(c-k) = settingedge_matrix(min_mean_vertex,c);
                   end
                   min_mean_cycle_end = v-k;
               end
               
           end
        end
    end
    %Find tau 
    tau = 0;
    for k = (1:min_mean_cycle_end)
        cap_k = res_capacities(settingedge_matrix(min_mean_vertex,k));
        if(cap_k<tau)
            tau = cap_k;
        end
    end
    
    circ_new=circ_current;
    for  k = (1:min_mean_cycle_end)
       edge = settingedge_matrix(min_mean_vertex,k);
       if(edge>size(forward_costs)) 
           circ_current(edge)= circ_current(edge)- tau;
       else
           circ_current(edge)= circ_current(edge)+ tau;
       end
    end
    
else
    circ_new=circ_current;
    return
end

%Reconstructing the graph from resG

 
end