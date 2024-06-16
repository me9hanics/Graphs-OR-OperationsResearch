import numpy as np
import networkx as nx

"""
The algorithm of Goldberg and Tarjan (1989): 

1) G=(V,A,f,g,k). Set ∀a∈A,g(a)=0 (demand). We set ∀a∈A k(a) = -1 (cost) for all arcs to maximize volume with minimum cost.
    Set the circulation function x0 =0, and i = 0 (iteration).

2) Run a (strongly polynomial time) minimum-cost circulation algorithm on graph G, and find the minimum cost circulation for compressing.

3) Acquire the maximum volume circulation.


We split 2) into two steps: First step: Create the residual 
graph G_x_i = (V, A_x_i) from graph G and circulation x_i, and find a minimum mean cycle X^C in G_x_i.
(X^C is a cycle, the ^C is a superscript, not a power of C.)
Let -𝜀_i be the value of the mean. Second step: If -𝜀_i < 0 then set x_{i+1} = x_i + 𝜏X^C,
where 𝜏 is the maximal possible amount to increase or decrease each flow in X^C (we add 𝜏 or take away 𝜏
from each arc in X^C, based on if flow is sent on a forward or reverse arc in the residual graph),
we add 1 to i and we go back to the first step in 2). 
Else, we know our graph is minimal cost, and we go to 3).
"""

def create_residual_graph(graph):
    resG = nx.DiGraph()
    for u, v, data in graph.edges(data=True):
        if data['flow'] < data['capacity']:
            resG.add_edge(u, v, capacity=data['capacity'] - data['flow'], cost=data['cost'])
        if data['flow'] > 0:
            resG.add_edge(v, u, capacity=data['flow'], cost=-data['cost'])
    return resG

def min_mean_cycle_0demand(graph):
    """
    Compute the minimum mean cycle in a graph, assuming 0 demand.

    This is 2) in the Goldberg and Tarjan algorithm.

    Karp showed that finding a minimum mean cost cycle can be done in O(mn) time (on strongly connected graphs,
    otherwise run this on each component). His algorithm, published in 1972:
    Let 0≤k≤n,d_k(v) be the minimum distance walk ending in vertex v with k arcs.
    We define this function as so: ∀v d_0(v)=0, d_(k+1)(v)=min{d_k(u)+c(a)|a=(u,v)∈A}, because
    the lowest distance k+1 arc walk to vertex v is a lowest distance walk with k arcs to some vertex u + the distance between u and v.

    Karp managed to prove that minimum mean of a directed cycle is equal to:

    min┬(u∈V)max┬(0≤k≤n-1)⁡〖(d_n (u)-d_k (u))/(n-k)〗 
    
    Furthermore, a minimum mean cycle is contained in the path that set d_n (u).
    We will use this to find X^C in 2), the distance function is the cost function.

    """

    #Assuming that dirG is a networkx graph, that has edge capacities and costs, and flow
    if not isinstance(graph, (nx.Graph, nx.DiGraph)):
        raise ValueError("Input graph must be a NetworkX Graph or DiGraph")
    for _, __, data in graph.edges(data=True):
        if ('capacity' not in data.keys()) or ('cost' not in data.keys()) or ('flow' not in data.keys()):
            raise ValueError("Input graph must have 'capacity', 'cost' and 'flow' attributes for each edge")

    resG = create_residual_graph(graph)
    n = resG.number_of_nodes()
    m = resG.number_of_edges()

    #Karp: Nx(N+1) matrix for distances. Initialize with infinities, except for d_0(u)=0
    distance_matrix = np.full((n, n+1), np.inf)
    distance_matrix[:, 0] = 0
    settingedge_matrix = np.full((n, n), -np.inf)

    #Distances (similar to Bellman-Ford)
    for k in range(n):
        for u, v, data in resG.edges(data=True):
            if distance_matrix[u, k] + data['cost'] < distance_matrix[v, k+1]:
                distance_matrix[v, k+1] = distance_matrix[u, k] + data['cost']
                settingedge_matrix[v, k] = (u, v)  # storing the edge that set it

    #Minimum mean cycle
    maxdiffs = np.full(n, -np.inf)
    for v in range(n):
        for k in range(n):
            if (distance_matrix[v, n] - distance_matrix[v, k]) / (n+1-k) > maxdiffs[v]:
                maxdiffs[v] = (distance_matrix[v, n] - distance_matrix[v, k]) / (n+1-k)
    min_mean_vertex = np.argmin(maxdiffs)
    min_mean = maxdiffs[min_mean_vertex]

    #a)If the minimum mean is less than 0, then we can improve on the cost
    if min_mean < 0:
        #Minimum mean cycle
        settingwalk = [settingedge_matrix[min_mean_vertex, k] for k in range(n)]
        settingwalk.append(settingedge_matrix[min_mean_vertex, n])

        min_mean_cycle = [settingedge_matrix[min_mean_vertex, k] for k in range(n) if settingwalk[k] == settingwalk[-1]]
        min_mean_cycle_end = len(min_mean_cycle)

        #Tau (amount to increase or decrease each flow in the cycle)
        tau = min([resG.edges[edge]['capacity'] for edge in min_mean_cycle])

        #Update the circulation
        circ_new = graph.copy()
        for edge in min_mean_cycle:
            if edge in graph.edges:
                circ_new.edges[edge]['flow'] += tau
            else:
                circ_new.edges[(edge[1], edge[0])]['flow'] -= tau
    else: #b)If the minimum mean is 0: we have a minimal cost circulation
        circ_new = graph.copy()
        tau = 0

    return circ_new#, tau