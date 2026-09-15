package synth.core.PattermEnumerator;

import synth.ast.pattern.EdgePattern;
import synth.core.data.dataStructures.Edge;
import synth.core.data.dataStructures.InputGraph;

import java.util.*;

import static synth.core.data.dataStructures.InputGraph.getNeighbors;

public class Graph2Pattern {

    public HashSet<String> visitedNodeIDs = new HashSet<>();
    public HashSet<String> visitedEdgeIDs = new HashSet<>();

    public HashSet<HashSet<String>> onLoop = new HashSet<>();
    public HashSet<HashSet<String>> results = new HashSet<>();
    public Boolean includeCycle = false;
    public ArrayList<InputGraph> backUpList = new ArrayList<>();
    public ArrayList<Pattern> getPattern(InputGraph graph) {
        graph.neighbors = getNeighbors(graph);
        if(graph.nodes.keySet().isEmpty()){
            return null;
        }
        Pattern originalPattern = helper(graph, (String) graph.nodes.keySet().toArray()[0], new HashSet<>(), new HashSet<>());
        ArrayList<Pattern> retPatterns = new ArrayList<>(Arrays.asList(originalPattern));
//        If there are loops in graph, split the loop to get complete sets of patterns
        if(this.onLoop.size() > 0){
            includeCycle = true;
            retPatterns.addAll(allPatternsFromGraph(new ArrayList<>(Arrays.asList(graph))));
        }
        return retPatterns;
    }

    public Pattern helper(InputGraph graph, String nodeID, HashSet<String> nodesOnPath, HashSet<String> edgesOnPath){
        Pattern currPattern = new Pattern();
        if(nodeID.contains("_")){
            nodeID = nodeID.substring(0, nodeID.indexOf("_"));
        }
        if(!visitedNodeIDs.contains(nodeID)){
            this.visitedNodeIDs.add(nodeID);
            nodesOnPath.add(nodeID);
            currPattern.nodePatterns.add(new NodePattern(graph.nodes.get(nodeID).label, "n"+nodeID));

            Integer edgeCnt = 0;
            if(graph.neighbors.containsKey(nodeID)){
                for(String edgeID: graph.neighbors.get(nodeID)) {
                    if (!edgesOnPath.contains(edgeID) && !visitedEdgeIDs.contains(edgeID)) {
                        Edge currEdge = graph.edges.get(edgeID);
                        String otherNodeID = currEdge.getOtherSide(nodeID);
                        if(otherNodeID.contains("_")){
                            otherNodeID = otherNodeID.substring(0, otherNodeID.indexOf("_"));
                        }
                        if(edgeCnt == 0){
                            edgesOnPath.add(edgeID);
                            this.visitedEdgeIDs.add(edgeID);

                            EdgePattern.Directions direction = EdgePattern.Directions.RIGHT;
                            if(!currEdge.getStart().equals(nodeID)){
                                direction = EdgePattern.Directions.LEFT;
                            }
                            currPattern.edgePatterns.add(new synth.core.PattermEnumerator.EdgePattern(currEdge.label, "e"+edgeID, direction));
                            if(!graph.nodes.containsKey(otherNodeID)){
                                return currPattern;
                            }
                            currPattern.nodePatterns.add(new NodePattern(graph.nodes.get(otherNodeID).label, "n"+otherNodeID));

                            Pattern laterPattern = helper(graph, otherNodeID, nodesOnPath, edgesOnPath);
                            currPattern = joinHelper(currPattern, laterPattern);

                            if(!laterPattern.basicPatterns.isEmpty()){
                                currPattern.basicPatterns.addAll(laterPattern.basicPatterns);
                            }
                        }
                        else {
                            this.visitedEdgeIDs.add(edgeID);
                            Pattern newPattern = new Pattern();
                            newPattern.nodePatterns.add(new NodePattern(graph.nodes.get(nodeID).label, "n"+nodeID));
                            EdgePattern.Directions direction = EdgePattern.Directions.RIGHT;
                            if(!currEdge.getStart().equals(nodeID)){
                                direction = EdgePattern.Directions.LEFT;
                            }
                            newPattern.edgePatterns.add(new synth.core.PattermEnumerator.EdgePattern(currEdge.label, "e"+edgeID, direction));
                            if(!graph.nodes.containsKey(otherNodeID)){
                                return currPattern;
                            }
                            newPattern.nodePatterns.add(new NodePattern(graph.nodes.get(otherNodeID).label, "n"+otherNodeID));

                            Pattern laterPattern = helper(graph, otherNodeID,  new HashSet<>(Arrays.asList(nodeID)), new HashSet<>(Arrays.asList(edgeID)));
                            newPattern = joinHelper(newPattern, laterPattern);

                            if(!laterPattern.basicPatterns.isEmpty()){
                                currPattern.basicPatterns.addAll(laterPattern.basicPatterns);
                            }
                            currPattern.basicPatterns.add(newPattern);
                        }
                        edgeCnt += 1;
                    }
                }
            }
        } else {
            this.onLoop.add(nodesOnPath);
        }
        return currPattern;
    }


    public void combineListIndices(ArrayList<HashSet<String>> listOfLists, int start, int k,
                                   ArrayList<HashSet<String>> selectedLists) {
        if (selectedLists.size() == k) {
            backtrack(selectedLists, 0, new ArrayList<>());
        }
        for (int i = start; i < listOfLists.size(); i++) {
            selectedLists.add(listOfLists.get(i));
            combineListIndices(listOfLists, i + 1, k, selectedLists);
            selectedLists.remove(selectedLists.size() - 1);
        }
    }


    private void backtrack(ArrayList<HashSet<String>> lists, int index, ArrayList<String> current) {
        if (index == lists.size()) {
            results.add(new HashSet<>(current));
        }
        if(lists.size() > index){
            for (String item : lists.get(index)) {
                current.add(item);
                backtrack(lists, index + 1, current);
                current.remove(current.size() - 1);
            }
        }
    }


    static class dfsHelper{
        ArrayList<InputGraph> complete = new ArrayList<>();

        void dfs(InputGraph currGraph, ArrayList<String> toAddBack, InputGraph original){
            if(currGraph.edges.size() == original.edges.size()){
                complete.add(currGraph);
            } else if (toAddBack.size() > 0){
                String edgeID = toAddBack.get(toAddBack.size()-1);
                if(!currGraph.edges.containsKey(edgeID)){
                    String startNodeID = original.edges.get(edgeID).getStart();
                    String endNodeID = original.edges.get(edgeID).getEnd();

                    for(int i = 0; i < 3; i++){
                        if(i==0){
                            // no new nodes added
                            InputGraph newGraph1 = currGraph.copy();
                            newGraph1.edges.put(edgeID, original.edges.get(edgeID).copy());
                            toAddBack.remove(toAddBack.size()-1);
                            dfs(newGraph1, toAddBack, original);
                            toAddBack.add(edgeID);
                        }
                        if(i==1){
                            // add new end node
                            InputGraph newGraph2 = currGraph.copy();
                            newGraph2.edges.put(edgeID, original.edges.get(edgeID).copy());
                            String newEndID = endNodeID + "_" + edgeID + "_extended";
                            newGraph2.edges.get(edgeID).setEnd(newEndID);
                            if(endNodeID.contains("_")){
                                newGraph2.nodes.put(newEndID, original.nodes.get(endNodeID.substring(0, endNodeID.indexOf('_'))).copy(newEndID));
                            } else {
                                newGraph2.nodes.put(newEndID, original.nodes.get(endNodeID).copy(newEndID));
                            }
                            toAddBack.remove(toAddBack.size()-1);
                            dfs(newGraph2, toAddBack, original);
                            toAddBack.add(edgeID);
                        }
                        if(i==2){
                            // add new start node
                            InputGraph newGraph3 = currGraph.copy();
                            newGraph3.edges.put(edgeID, original.edges.get(edgeID).copy());
                            String newStartID = startNodeID + "_" + edgeID + "_extended";
                            newGraph3.edges.get(edgeID).setStart(newStartID);
                            if(startNodeID.contains("_")){
                                newGraph3.nodes.put(newStartID, original.nodes.get(startNodeID.substring(0, startNodeID.indexOf('_'))).copy(newStartID));
                            } else {
                                newGraph3.nodes.put(newStartID, original.nodes.get(startNodeID).copy(newStartID));
                            }
                            toAddBack.remove(toAddBack.size()-1);
                            dfs(newGraph3, toAddBack, original);
                            toAddBack.add(edgeID);
                        }
                    }
                }
            }
        }
    }


    public ArrayList<Pattern> allPatternsFromGraph(ArrayList<InputGraph> graphs) {
        ArrayList<Pattern> patterns = new ArrayList<>();
        ArrayList<InputGraph> workList = new ArrayList<>();
        Integer upperLimit = 10000;

        // 1. For the graph, find all spanning tree in it, then add to workList;
        MultiPatterns spanningTreeHelper = new MultiPatterns();
        ArrayList<InputGraph> trees = spanningTreeHelper.allTrees(graphs.get(0));
        // number of nodes in each tree should be the same as nodes in graph
        for(InputGraph tree : trees){
            Boolean nodesInc = true;
            Boolean edgesInc = true;
            for(String key : tree.nodes.keySet()){
                if(!graphs.get(0).nodes.containsKey(key)){
                    nodesInc = false;
                    break;
                }
            }
            for(String key : tree.edges.keySet()){
                if(!graphs.get(0).edges.containsKey(key)){
                    edgesInc = false;
                    break;
                }
            }

            if(nodesInc && edgesInc){
                workList.add(tree);
            }
        }


        // 2. For each spanning tree, for each edge neglected, add it back with dfs, till hit size limit;
        int patternCounter = 0;
        int treePt = 0;
        for(InputGraph tree : workList){
            treePt++;
            dfsHelper dfsHelper = new dfsHelper();
            ArrayList<String> toAddBack = new ArrayList<>();
            for (String edgeID: graphs.get(0).edges.keySet()){
                if(!tree.edges.containsKey(edgeID)){
                    toAddBack.add(edgeID);
                }
            }
            dfsHelper.dfs(tree, toAddBack, graphs.get(0));
            for (InputGraph completedGraph : dfsHelper.complete) {
                completedGraph.neighbors = getNeighbors(completedGraph);
                Pattern currPattern = new Graph2Pattern().helper(completedGraph, (String) completedGraph.nodes.keySet().toArray()[0], new HashSet<>(), new HashSet<>());
                patterns.add(currPattern);
                patternCounter++;
                if (patternCounter >= upperLimit) {
                    break;
                }
            }
        }

        if(patternCounter >= upperLimit){
            backUpList.addAll(workList.subList(treePt, workList.size()));
        }
        return patterns;
    }

    /*
        Join two part of paths into one path
     */
    public static Pattern joinHelper(Pattern patternA, Pattern patternB){
        if(patternB.nodePatterns.size() > 1){
            patternA.nodePatterns.addAll(patternB.nodePatterns.subList(1, patternB.nodePatterns.size()));
        }
        patternA.edgePatterns.addAll(patternB.edgePatterns);
        return patternA;
    }
}
