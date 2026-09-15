package synth.core.PattermEnumerator;

import synth.core.data.dataStructures.Edge;
import synth.core.data.dataStructures.InputGraph;
import synth.core.data.dataStructures.Node;

import java.util.*;

public class MultiPatterns {
    
    /*
        Intermediate data structure between Edge in InputGraph to edge in this class
     */
    class edge {
        int u, v, w;
        String actualEdgeID;

        public edge(int u, int v, int w, String actualEdgeID) {
            this.u = u;
            this.v = v;
            this.w = w;
            this.actualEdgeID = actualEdgeID;
        }
    }

    HashMap<Integer, String> toActualNodeID = new HashMap<>();
    HashMap<String, Integer> fromActualNodeID = new HashMap<>();
    List<edge> edges = new ArrayList<>();
    InputGraph inputGraph;

    void fromActual(InputGraph inputGraph) {
        this.inputGraph = inputGraph;
        int nodeID=0;
        for(String actualNodeID: inputGraph.nodes.keySet()){
            toActualNodeID.put(nodeID, actualNodeID);
            fromActualNodeID.put(actualNodeID, nodeID);
            nodeID++;
        }
        for (String actualEdgeID: inputGraph.edges.keySet()) {
            int u = fromActualNodeID.get(inputGraph.edges.get(actualEdgeID).getStart());
            int v = fromActualNodeID.get(inputGraph.edges.get(actualEdgeID).getEnd());
            edges.add(new edge(u, v, 1, actualEdgeID));
        }
    }

    InputGraph toActual(List<edge> resultGraph) {
        HashMap<String, Node> nodes = new HashMap<>();
        HashMap<String, Edge> edges = new HashMap<>();

        for (edge e:resultGraph) {
            int u = e.u;
            String actualUID = toActualNodeID.get(u);
            int v = e.v;
            String actualVID = toActualNodeID.get(v);
            String actualEdgeID = e.actualEdgeID;
            edges.put(actualEdgeID, this.inputGraph.edges.get(actualEdgeID));
            nodes.put(actualUID, this.inputGraph.nodes.get(actualUID));
            nodes.put(actualVID, this.inputGraph.nodes.get(actualVID));
        }
        InputGraph toActualResultGraph = new InputGraph(nodes, edges);
        return toActualResultGraph;
    }

    /*
        Entry point for the class MultiPatterns
     */
    ArrayList<InputGraph> allTrees(InputGraph inputGraph) {
        ArrayList<InputGraph> aTrees = new ArrayList<>();
        fromActual(inputGraph);
        findAllMSTs(inputGraph.nodes.size(), edges);
        for(List<edge> res: result){
            InputGraph resInputGraph = toActual(res);
            aTrees.add(resInputGraph);
        }
        return aTrees;
    }
    
    static class UnionFind {
        int[] parent, rank;

        public UnionFind(int n) {
            parent = new int[n];
            rank = new int[n];
            for (int i = 0; i < n; i++)
                parent[i] = i;
        }

        public UnionFind(UnionFind other) {
            this.parent = other.parent.clone();
            this.rank = other.rank.clone();
        }

        int find(int x) {
            if (parent[x] != x)
                parent[x] = find(parent[x]);
            return parent[x];
        }

        boolean union(int x, int y) {
            int rx = find(x);
            int ry = find(y);
            if (rx == ry) return false;

            if (rank[rx] < rank[ry])
                parent[rx] = ry;
            else if (rank[rx] > rank[ry])
                parent[ry] = rx;
            else {
                parent[ry] = rx;
                rank[rx]++;
            }
            return true;
        }
    }

    private final List<List<edge>> result = new ArrayList<>();

    void findAllMSTs(int V, List<edge> edges) {

        edges.sort(Comparator.comparingInt(e -> e.w));

        Map<Integer, List<edge>> groups = new LinkedHashMap<>();
        for (edge e : edges) {
            groups.computeIfAbsent(e.w, k -> new ArrayList<>()).add(e);
        }

        List<List<edge>> weightGroups = new ArrayList<>(groups.values());

        backTrack(0, V, weightGroups, new UnionFind(V), new ArrayList<>());
    }

    void backTrack(int groupIndex,
                          int V,
                          List<List<edge>> groups,
                          UnionFind uf,
                          List<edge> current) {

        if (groupIndex == groups.size()) {
            if (current.size() == V - 1)
                result.add(new ArrayList<>(current));
            return;
        }

        List<edge> group = groups.get(groupIndex);

        List<edge> candidates = new ArrayList<>();
        for (edge e : group) {
            if (uf.find(e.u) != uf.find(e.v))
                candidates.add(e);
        }

        int needed = 0;
        UnionFind tempUF = new UnionFind(uf);
        for (edge e : candidates) {
            if (tempUF.union(e.u, e.v))
                needed++;
        }

        enumerateSubsets(candidates, 0, needed,
                uf, current,
                groupIndex, V, groups);
    }

    void enumerateSubsets(List<edge> candidates,
                                 int index,
                                 int needed,
                                 UnionFind uf,
                                 List<edge> current,
                                 int groupIndex,
                                 int V,
                                 List<List<edge>> groups) {

        if (needed == 0) {
            backTrack(groupIndex + 1, V, groups, uf, current);
            return;
        }

        if (index == candidates.size())
            return;

        edge e = candidates.get(index);

        if (uf.union(e.u, e.v)) {
            current.add(e);
            enumerateSubsets(candidates, index + 1, needed - 1,
                    uf, current, groupIndex, V, groups);
            current.remove(current.size() - 1);

            uf.parent[e.u] = e.u;
            uf.parent[e.v] = e.v;
        }

        enumerateSubsets(candidates, index + 1, needed,
                uf, current, groupIndex, V, groups);
    }
}
