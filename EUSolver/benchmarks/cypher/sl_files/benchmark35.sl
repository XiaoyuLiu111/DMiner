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
(NodeLabels String ("User" "Item"))
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("likes"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ())

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((COUNT AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "10", "label": "User"}, {"element_id": "11", "label": "User"}, {"element_id": "12", "label": "User"}, {"element_id": "13", "label": "User"}, {"element_id": "14", "label": "Item"}, {"element_id": "15", "label": "Item"}, {"element_id": "16", "label": "Item"}, {"element_id": "17", "label": "Item"}, {"element_id": "18", "label": "Item"}, {"element_id": "19", "label": "Item"}], "edges": [{"label": "likes", "element_id": "9", "start": "10", "end": "19"}, {"label": "likes", "element_id": "10", "start": "11", "end": "14"}, {"label": "likes", "element_id": "11", "start": "13", "end": "19"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}, {"inputItems": ["n19"], "property": "full", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n19"], "property": "full", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1, 2], [3, 4]]}>>))


(check-synth)
                