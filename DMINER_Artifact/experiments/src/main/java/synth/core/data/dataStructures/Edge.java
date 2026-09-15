package synth.core.data.dataStructures;

import java.util.LinkedHashMap;

public class Edge {
    public final String label;
    private final LinkedHashMap<String, Object> attributes;

    public LinkedHashMap<String, Object> getAttributes() {
        return attributes;
    }

    public String getStart() {
        return start;
    }

    public String getEnd() {
        return end;
    }

    public void setStart(String start) {
        this.start = start;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public String getId() {
        return id;
    }
    public String TId;
    public Integer exampleID;

    public String getTId() {
        return TId;
    }

    public void setTId(String TId) {
        this.TId = TId;
    }

    private String start;
    private String end;
    private final String id;
    public final Boolean biDirection;

    public Edge(String label, LinkedHashMap<String, Object> attributes, String start, String end, String id, Boolean biDirection) {
        this.label = label;
        this.attributes = attributes;
        this.start = start;
        this.end = end;
        this.id = id;
        this.biDirection = biDirection;
    }

    public boolean contains(LinkedHashMap<String, Object> edge2){
        return this.attributes.entrySet().containsAll(edge2.entrySet());
    }

    public String getOtherSide(String oneSide){
        if(this.getStart().equals(oneSide)){
            return this.getEnd();
        } else {
            return this.getStart();
        }
    }

    public Edge copy(){
        return new Edge(label, attributes, start, end, id, biDirection);
    }
}
