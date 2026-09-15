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
(NodeLabels String ("Bank" "Person"))
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("WORKS_AT" "BANKS_AT"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0" "n1"))
(EdgeVars String ("e0"))
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


(constraint (= (f <<{"nodes": [{"element_id": "1", "label": "Person"}, {"element_id": "2", "label": "Person"}, {"element_id": "3", "label": "Person"}, {"element_id": "4", "label": "Bank"}, {"element_id": "5", "label": "Bank"}], "edges": [{"label": "WORKS_AT", "element_id": "0", "start": "1", "end": "4"}, {"label": "BANKS_AT", "element_id": "1", "start": "3", "end": "4"}, {"label": "WORKS_AT", "element_id": "2", "start": "2", "end": "5"}, {"label": "BANKS_AT", "element_id": "3", "start": "3", "end": "5"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}], "table": [[1, 2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "1", "label": "Person"}, {"element_id": "2", "label": "Person"}, {"element_id": "3", "label": "Person"}, {"element_id": "4", "label": "Bank"}, {"element_id": "5", "label": "Bank"}], "edges": [{"label": "BANKS_AT", "element_id": "1", "start": "1", "end": "4"}, {"label": "BANKS_AT", "element_id": "2", "start": "1", "end": "5"}, {"label": "BANKS_AT", "element_id": "4", "start": "2", "end": "4"}, {"label": "BANKS_AT", "element_id": "5", "start": "3", "end": "5"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}], "table": [[1, 2, 3, 4]]}>>))


(check-synth)
                