nodes = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'}';
nodeTable = table(nodes,'VariableNames',{'Name'});
from = [1 1 2 3 3 4 5 5 6];
ends = [2 4 3 2 7 5 6 3 4];
capacities = [2 7 3 5 4 2 8 3 3];
demands = zeros(size(from));
costs = -ones(size(from));
edgeflow = [0 0 2 2 0 1 1 0 1];
edgeTable = table([from' ends'], capacities', demands', costs', edgeflow', 'VariableNames',{'EndNodes' 'Capacities' 'Demands' 'Costs' 'Flow'});
%G = digraph(nodeTable,edgeTable)
G = digraph(edgeTable, nodeTable);
Y = [G.Edges.Capacities G.Edges.Costs G.Edges.Demands G.Edges.Flow];
x = sprintf('%d %d %d %d, ',[G.Edges.Capacities.';G.Edges.Costs.';G.Edges.Demands.';G.Edges.Flow.'])
t = sscanf(x ,'%d %d %d %d, ', [36 1])
plot(G,'NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Capacities);
%savefig('cubegraph.fig');
%y = openfig('cubegraph.fig');

%size(capacities,2)
%demands = zeros(size(from))
%costs = -ones(size(from))
%random = ones(3)/0
%Y=ones(size(G.Nodes,1),size(G.Edges,1));
%Y(:,1)=0

%highlight();

%G.Edges.Weight;
%size(G.Edges.Weight);
%plot(G,'EdgeLabel',G.Edges.Weight,'Layout','layered');