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
(NodeLabels String ("Me" "User"))
(NodeProperty String ("following" "name" "follwers" "userID"))
                    
; Edge Information
(EdgeLabels String ("AMPLIFIES" "FOLLOWS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n4" "n3" "n2" "n1" "n0"))
(EdgeVars String ("e3" "e2" "e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ())

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((COUNT AggregatorsSub)
                     (SUM AggregatorsSub)
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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Me", "following": 10124, "follwers": 34507, "name": "Neo4j"}, {"element_id": "1", "label": "User", "following": 51280, "name": "Right Relevance", "follwers": 51280}, {"element_id": "2", "label": "User", "following": 1124, "follwers": 1124, "name": "Philip Rathle"}, {"element_id": "3", "label": "User", "following": 162, "follwers": 162, "name": "Brant Boehmann"}, {"element_id": "4", "label": "User", "following": 1568, "follwers": 1568, "name": "NetScience"}, {"element_id": "5", "label": "User", "following": 47, "follwers": 47, "name": "Stuart Laurie"}], "edges": [{"label": "FOLLOWS", "element_id": "0", "start": "1", "end": "0"}, {"label": "FOLLOWS", "element_id": "1", "start": "5", "end": "0"}, {"label": "AMPLIFIES", "element_id": "2", "start": "0", "end": "3"}, {"label": "FOLLOWS", "element_id": "10", "start": "0", "end": "2"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"inputItems": ["n2", "n2"], "property": "following", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n2", "n2"], "property": "following", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n2", "n2"], "property": "following", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["n2", "n2"], "property": "following", "operator": "avg", "lhs": {}, "rhs": {}}], "table": [[1], [2], [3], [4], [5]]}>>))


(check-synth)
                