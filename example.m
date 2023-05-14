from = [1 1 2 3 3 4 5 5 6];
ends = [2 4 3 2 7 5 6 3 4];
capacities = [2 7 3 5 4 2 8 3 3];
edgeflow = [0 0 2 2 0 1 1 0 1];
demands = zeros(size(from));
costs = -ones(size(from));

EdgeTable = table([from' ends'],capacities',edgeflow',demands',costs','VariableNames',{'EndNodes' 'Capacity' 'Edgeflow' 'Demands' 'Costs'});

names = {'1' '2' '3' '4' '5' '6' '7' '8'}';

NodeTable = table(names,'VariableNames',{'Name' });

G = digraph(EdgeTable,NodeTable);
plot(G,'NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Capacity);



zerotable = zeros(size(G.Nodes));
Sums = table(zerotable,'VariableNames',{'Difference' });
Nodesum = [G.Nodes Sums];
circulation = "True";
for v = 1:(size(G.Nodes,1))
    nodechecked=Nodesum.Name(v,1);
    for i=1:(size(G.Edges,1))
        startnode = G.Edges.EndNodes(i,1);
        endnode = G.Edges.EndNodes(i,2);
        if(ismember(startnode,nodechecked))
            Nodesum{v,2}=Nodesum{v,2}-G.Edges.Edgeflow(i,1);
        end
        if(ismember(endnode,nodechecked))
            Nodesum{v,2}=Nodesum{v,2}+G.Edges.Edgeflow(i,1);
        end
    end
end

for v = 1:(size(G.Nodes,1))
    if not(Nodesum{v,2}==0)
        circulation = "False";
    end
end