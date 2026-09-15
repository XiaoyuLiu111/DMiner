(set-logic CYPHER)

; This is the framework for the grammar that can then just be "filled in" for each benchmark

(synth-fun f ((input Graph)) Graph

((Start Graph (Return))
(Input Graph (input))
(Return Graph ((return Clause ReturnList)))
(Clause Graph ((match Input PathPattern) (matchr Clause PathPattern) (filter Clause Predicate)))
                    
; Patterns
(NodePattern String ((createNodePattern NodeVars NodeLabels)))
(EdgePattern String ((createEdgePattern EdgeVars EdgeLabels Direction)))
(Direction String ("->" "<-"))
(PathPattern String (NodePattern
                    (createPathPattern NodePattern EdgePattern PathPattern)))
                    
; Node Information 
(NodeLabels String ("Tag" "Question"))
(NodeProperty String ("viewCount" "name"))
                    
; Edge Information
(EdgeLabels String ("TAGGED"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("70" "35" "60"))

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((COUNT AggregatorsSub)
                     (AVG AggregatorsSub)
                     (MIN AggregatorsSub)
                     (MAX AggregatorsSub)))

; AggregatorsSub
(AggregatorsSub String (EdgeVars
                       NodeVars
                       Properties))

; Expressions
(Expression String (Values
                    Properties
                    (eadd Expression Expression)
                    (esub Expression Expression)
                    (emul Properties Values)))

; Return Atoms
(ReturnAtom String (Aggregators
                    Properties
                    EdgeVars
                    NodeVars))

; Predicates
(Predicate String ((equal Expression Expression)
                    (ene Expression Expression)
                    (elt Expression Expression)
                    (elte Expression Expression)
                    (pand Predicate Predicate)
                    (por Predicate Predicate)))

; Expression List
(ExpressionList String (Expression (createExpressionList ExpressionList Expression)))

; Return List
(ReturnList String (ReturnAtom (createReturnList ReturnList ReturnAtom)))))


(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Tag", "name": "postgresql"}, {"element_id": "5", "label": "Tag", "name": "graphrag"}, {"element_id": "6", "label": "Question", "viewCount": 60}, {"element_id": "7", "label": "Question", "viewCount": 69}], "edges": [{"label": "TAGGED", "element_id": "2", "start": "7", "end": "5"}, {"label": "TAGGED", "element_id": "3", "start": "6", "end": "4"}]}>>) 
                <<{"outputGraph": [{"inputItems": ["n6"], "property": "viewCount", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n6"], "property": "viewCount", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["n6"], "property": "viewCount", "operator": "avg", "lhs": {}, "rhs": {}}, {"inputItems": ["n6"], "property": "viewCount", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1], [2], [3], [4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "Tag", "name": "python-3.x"}, {"element_id": "9", "label": "Tag", "name": "java"}, {"element_id": "10", "label": "Question", "viewCount": 35}, {"element_id": "11", "label": "Tag", "name": "python2"}, {"element_id": "12", "label": "Tag", "name": "odbc"}, {"element_id": "13", "label": "Question", "viewCount": 62}, {"element_id": "14", "label": "Question", "viewCount": 71}, {"element_id": "15", "label": "Question", "viewCount": 27}], "edges": [{"label": "TAGGED", "element_id": "4", "start": "15", "end": "11"}, {"label": "TAGGED", "element_id": "5", "start": "14", "end": "12"}, {"label": "TAGGED", "element_id": "6", "start": "13", "end": "9"}, {"label": "TAGGED", "element_id": "7", "start": "10", "end": "8"}]}>>) 
                <<{"outputGraph": [{"inputItems": ["n10", "n14"], "property": "viewCount", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n10", "n14"], "property": "viewCount", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["n10", "n14"], "property": "viewCount", "operator": "avg", "lhs": {}, "rhs": {}}, {"inputItems": ["n10", "n14"], "property": "viewCount", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1], [2], [3], [4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "Tag", "name": "python"}, {"element_id": "9", "label": "Tag", "name": "postgresql"}, {"element_id": "10", "label": "Tag", "name": "odbc"}, {"element_id": "11", "label": "Tag", "name": "c++"}, {"element_id": "12", "label": "Question", "viewCount": 34}, {"element_id": "13", "label": "Question", "viewCount": 37}, {"element_id": "14", "label": "Question", "viewCount": 32}, {"element_id": "15", "label": "Question", "viewCount": 61}], "edges": [{"label": "TAGGED", "element_id": "4", "start": "12", "end": "8"}, {"label": "TAGGED", "element_id": "5", "start": "13", "end": "9"}, {"label": "TAGGED", "element_id": "6", "start": "14", "end": "10"}, {"label": "TAGGED", "element_id": "7", "start": "15", "end": "11"}]}>>) 
                <<{"outputGraph": [{"inputItems": ["n13"], "property": "viewCount", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n13"], "property": "viewCount", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["n13"], "property": "viewCount", "operator": "avg", "lhs": {}, "rhs": {}}, {"inputItems": ["n13"], "property": "viewCount", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1], [2], [3], [4]]}>>))


(check-synth)
                