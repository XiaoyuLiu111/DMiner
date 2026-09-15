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
(NodeLabels String ("Person" "Bank"))
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("WORKS_AT" "BANKS_AT"))
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
(Aggregators String ())

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
(ReturnAtom String (Properties
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


(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Person"}, {"element_id": "7", "label": "Bank", "name": "XYZ Bank", "id": 123}, {"element_id": "8", "label": "Person"}, {"element_id": "9", "label": "Person"}, {"element_id": "10", "label": "Bank", "name": "Bank", "id": 0}, {"element_id": "11", "label": "Person"}], "edges": [{"label": "WORKS_AT", "element_id": "0", "start": "6", "end": "7"}, {"label": "BANKS_AT", "element_id": "1", "start": "8", "end": "7"}, {"label": "BANKS_AT", "element_id": "8", "start": "6", "end": "7"}, {"label": "BANKS_AT", "element_id": "9", "start": "9", "end": "10"}, {"label": "WORKS_AT", "element_id": "10", "start": "9", "end": "10"}, {"label": "WORKS_AT", "element_id": "11", "start": "11", "end": "10"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "full"}], "table": [[1, 2]]}>>))


(check-synth)
                