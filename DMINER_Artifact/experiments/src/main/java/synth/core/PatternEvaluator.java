package synth.core;

import org.neo4j.driver.Driver;
import org.neo4j.driver.EagerResult;
import org.neo4j.driver.QueryConfig;
import synth.ast.AstVisitor;
import synth.ast.IAstVisitor;
import synth.ast.clause.Return;
import synth.ast.clause.SingleMatch;
import synth.ast.pattern.ItemPattern;
import synth.ast.pattern.PathPattern;
import synth.ast.pred.expr.Property;
import synth.ast.propertyList.PropertyList;
import synth.core.PattermEnumerator.EdgePattern;
import synth.core.PattermEnumerator.NodePattern;
import synth.core.PattermEnumerator.Pattern;
import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.Edge;
import synth.core.data.dataStructures.Node;

import java.util.*;

public class PatternEvaluator{
    public static class ReturnQuery{
        public ReturnQuery(ArrayList<String> variableName, ArrayList<ArrayList<String>> vals) {
            this.variableName = variableName;
            this.vals = vals;
        }

        public ArrayList<String> variableName;
        public ArrayList<ArrayList<String>> vals;
    }

    public PatternEvaluator(Driver driver) {
        this.driver = driver;
    }

    public Driver driver;
    public ReturnQuery evaluate(String query, String databaseName, Integer demonstrationID){
        ArrayList<ArrayList<String>> results = new ArrayList<>();
        EagerResult result = this.driver.executableQuery(query).withConfig(QueryConfig.builder().withDatabase(databaseName).build()).execute();
        for(int i=0; i< result.records().size(); i++) {
            ArrayList<String> row = new ArrayList<>();
            for(var val: result.records().get(i).values()){
                if(val.getClass().toString().endsWith("NodeValue")){
                    String nodeID = String.valueOf(val.asNode().id());
                    row.add("d" + demonstrationID + "_n" + nodeID);
                } else {
                    String edgeID = String.valueOf(val.asRelationship().id());
                    row.add("d" + demonstrationID + "_e" + edgeID);
                }
            }
            results.add(row);
        }
        if(result.records().isEmpty()){
            return null;
        }
        ReturnQuery toReturn = new ReturnQuery(new ArrayList<>(result.records().get(0).keys()), results);
        return toReturn;
    }

    public static LinkedHashMap<String, ArrayList<String>> varName2Properties(ArrayList<String> varNames, ArrayList<String> sampleValues, ArrayList<Demonstration> demonstrations){
        LinkedHashMap<String, ArrayList<String>> varName2Properties = new LinkedHashMap<>();

        Integer demonstrationID = Integer.valueOf(sampleValues.get(0).split("_")[0].replace("d", ""));
        for (int i=0; i<sampleValues.size(); i++){
            String val = sampleValues.get(i);
            String dataID = val.split("_")[1];
            if(dataID.startsWith("n")){
                Node node = demonstrations.get(demonstrationID).inputGraph.nodes.get(dataID.replace("n", ""));
                varName2Properties.put(varNames.get(i), new ArrayList<>(node.getAttributes().keySet()));
            } else if(dataID.startsWith("e")){
                Edge edge = demonstrations.get(demonstrationID).inputGraph.edges.get(dataID.replace("e", ""));
                varName2Properties.put(varNames.get(i), new ArrayList<>(edge.getAttributes().keySet()));
            }
        }

        return varName2Properties;
    }

    public static LinkedHashMap<String, ArrayList<String>> varName2Labels(ArrayList<String> varNames, ArrayList<String> sampleValues, ArrayList<Demonstration> demonstrations){
        LinkedHashMap<String, ArrayList<String>> varName2Labels = new LinkedHashMap<>();

        Integer demonstrationID = Integer.valueOf(sampleValues.get(0).split("_")[0].replace("d", ""));
        for (int i=0; i<sampleValues.size(); i++){
            String val = sampleValues.get(i);
            String dataID = val.split("_")[1];
            if(dataID.startsWith("n")){
                Node node = demonstrations.get(demonstrationID).inputGraph.nodes.get(dataID.replace("n", ""));
                varName2Labels.put(varNames.get(i), new ArrayList<>(Arrays.asList(node.label)));
            } else if(dataID.startsWith("e")){
                Edge edge = demonstrations.get(demonstrationID).inputGraph.edges.get(dataID.replace("e", ""));
                varName2Labels.put(varNames.get(i), new ArrayList<>(Arrays.asList(edge.label)));
            }
        }

        return varName2Labels;
    }

    public static class toQueryObj{
        public HashSet<String> properties;
        public ArrayList<ArrayList<ItemPattern>> pattern;

        public toQueryObj(HashSet<String> properties, ArrayList<ArrayList<ItemPattern>> pattern) {
            this.properties = properties;
            this.pattern = pattern;
        }
    }

    public static String pattern2Query(Pattern pattern){
        IAstVisitor visitor = new AstVisitor();

        toQueryObj toQ = pattern2QueryHelper(pattern);

        ArrayList<Property> allProperties = new ArrayList<>();
        for(String varName: toQ.properties){
            allProperties.add(new Property(null, varName));
        }
        Return ast = new Return(new SingleMatch(new PathPattern(toQ.pattern)), new PropertyList(allProperties));
        String query = ast.astAccept(visitor);

        return query;
    }

    public static toQueryObj pattern2QueryHelper(Pattern pattern){

        ArrayList<ArrayList<ItemPattern>> allPatterns = new ArrayList<>();
        HashSet<String> properties = new HashSet<>();

        ArrayList<ItemPattern> onePath = new ArrayList<>();
        for(int i=0; i<pattern.nodePatterns.size(); i++){
            NodePattern node = pattern.nodePatterns.get(i);
            synth.ast.pattern.NodePattern nodePattern = new synth.ast.pattern.NodePattern(node.label, null);
            nodePattern.variableName = node.variableName;
            onePath.add(nodePattern);
            properties.add(node.variableName);

            if(i < pattern.nodePatterns.size() - 1){
                EdgePattern edge = pattern.edgePatterns.get(i);
                onePath.add(new synth.ast.pattern.EdgePattern(edge.variable, edge.label, null, null, null, edge.direction));
                properties.add(edge.variable);
            }
        }
        allPatterns.add(onePath);

        for(Pattern otherBranches: pattern.basicPatterns){
            toQueryObj toQ = pattern2QueryHelper(otherBranches);
            allPatterns.addAll(toQ.pattern);
            properties.addAll(toQ.properties);
        }

        return new toQueryObj(properties, allPatterns);
    }

    public ArrayList<ArrayList<String>> dedup(ArrayList<ArrayList<String>> vals){
        ArrayList<ArrayList<String>> deduped = new ArrayList<>();
        HashSet<HashMap<String, Integer>> dedupedSet = new HashSet<>();
        for(int rowId=0; rowId<vals.size(); rowId++){
            HashMap<String, Integer> dataCnt = new HashMap<>();
            for(String data: vals.get(rowId)){
                if(!dataCnt.containsKey(data)){
                    dataCnt.put(data, 0);
                }
                dataCnt.put(data, dataCnt.get(data) + 1);
            }
            if(!dedupedSet.contains(dataCnt)){
                dedupedSet.add(dataCnt);
                deduped.add(vals.get(rowId));
            }
        }
        return deduped;
    }
}
