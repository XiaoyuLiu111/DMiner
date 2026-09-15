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
(NodeLabels String ("Person"))
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("KNOWS"))
(EdgeProperty String ("duration"))

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("1" "0"))

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((SUM AggregatorsSub)
                     (AVG AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Person"}, {"element_id": "7", "label": "Person"}, {"element_id": "8", "label": "Person"}, {"element_id": "9", "label": "Person"}, {"element_id": "10", "label": "Person"}, {"element_id": "11", "label": "Person"}], "edges": [{"label": "KNOWS", "element_id": "21", "start": "6", "end": "7", "duration": 6}, {"label": "KNOWS", "element_id": "22", "start": "6", "end": "10", "duration": 10}, {"label": "KNOWS", "element_id": "23", "start": "6", "end": "11", "duration": 1.2}, {"label": "KNOWS", "element_id": "24", "start": "8", "end": "9", "duration": 26}]}>>) 
                <<{"outputGraph": [{"inputItems": ["e21", "e22", "e23", "e24"], "property": "duration", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["e21", "e22", "e23", "e24"], "property": "duration", "operator": "avg", "lhs": {}, "rhs": {}}], "table": [[1], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person"}, {"element_id": "1", "label": "Person"}, {"element_id": "2", "label": "Person"}, {"element_id": "3", "label": "Person"}, {"element_id": "4", "label": "Person"}], "edges": [{"label": "KNOWS", "element_id": "8", "start": "0", "end": "1", "duration": 5}, {"label": "KNOWS", "element_id": "9", "start": "1", "end": "2", "duration": 3}, {"label": "KNOWS", "element_id": "10", "start": "0", "end": "2", "duration": 10}, {"label": "KNOWS", "element_id": "11", "start": "3", "end": "4", "duration": 2}]}>>) 
                <<{"outputGraph": [{"inputItems": ["e8", "e9", "e10", "e11"], "property": "duration", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["e8", "e9", "e10", "e11"], "property": "duration", "operator": "avg", "lhs": {}, "rhs": {}}], "table": [[1], [2]]}>>))


(check-synth)
                