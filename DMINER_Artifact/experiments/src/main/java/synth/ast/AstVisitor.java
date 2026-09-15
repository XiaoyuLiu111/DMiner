package synth.ast;

import synth.ast.clause.*;
import synth.ast.pattern.ItemPattern;
import synth.ast.pattern.PathPattern;
import synth.ast.pred.IPredVisitor;
import synth.ast.pred.PredVisitor;
import synth.ast.pred.Predicate;
import synth.ast.propertyList.PropertyList;

import java.util.ArrayList;
import java.util.HashSet;

public class AstVisitor implements IAstVisitor{
    @Override
    public String visit(PropertyList propertyList){
        IPredVisitor predicateVisitor = new PredVisitor();
        ArrayList<String> properties = new ArrayList<>();
        for (Predicate property: propertyList.properties){
            properties.add(property.accept(predicateVisitor));
        }
        return String.join(", ", properties);
    }

    @Override
    public String visit(PathPattern pathPattern){
        StringBuilder joined = new StringBuilder();
        int i = 0;
        for(ArrayList<ItemPattern> itemPatterns: pathPattern.patterns){
            for (ItemPattern itemPattern: itemPatterns){
                joined.append(itemPattern.toCypher());
            }
            if(pathPattern.patterns.size()>1 && i < pathPattern.patterns.size()-1){
                joined.append(", ");
            }
            i++;
        }
        return joined.toString();
    }

    @Override
    public String visit(Return returnClause){
        if(returnClause.propertyList!=null){
            return returnClause.clause.astAccept(this) + "RETURN " + returnClause.propertyList.astAccept(this);
        } else {
            return returnClause.clause.astAccept(this) + "RETURN ";
        }
    }

    @Override
    public String visit(SingleMatch singleMatch) {
        return "MATCH " + singleMatch.pathPattern.astAccept(this) + " ";
    }

    @Override
    public String visit(MultipleMatch multipleMatch) {
        return multipleMatch.clause.astAccept(this) + multipleMatch.match.astAccept(this);
    }

    @Override
    public String visit(FilterClause filterClause) {
        IPredVisitor predicateVisitor = new PredVisitor();
        String toReturn = null;
        if(filterClause.predicate != null) {
            toReturn = filterClause.clause.astAccept(this) + "WHERE " + filterClause.predicate.accept(predicateVisitor) + " ";
        }
        else{
            toReturn = filterClause.clause.astAccept(this);
        }
        return toReturn;
    }

    @Override
    public String visit(With with) {
        IPredVisitor predicateVisitor = new PredVisitor();
        ArrayList<String> aggregations = new ArrayList<>();
        for (int i=0; i < with.aggregations.size(); i++){
            aggregations.add(with.aggregations.get(i).accept(predicateVisitor) + " as " + with.variables.get(i).accept(predicateVisitor));
        }
        return "WITH " + String.join(", ", aggregations) + " ";
    }

//    @Override
//    public String visit(AbstractFilter abstractFilter){
//        return abstractFilter.clause.astAccept(this) + "WHERE " + "Include " + abstractFilter.filter.toInclude.toString() +
//                "Exclude " + abstractFilter.filter.toExclude.toString();
//    }

}
