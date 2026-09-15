package synth.core.data.dataStructures;

public class DataStructure {
    public static class Pair{
        public Pair(Object first, Object second) {
            this.first = first;
            this.second = second;
        }

        public Object first;
        public Object second;
        public DataStructure.Pair copy(){
            return new DataStructure.Pair(this.first, this.second);
        }
    }
}
