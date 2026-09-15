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
(NodeLabels String ("Name" "Race" "City" "Group" "Age"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("R"))
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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Group", "name": "Group1"}, {"element_id": "1", "label": "Group", "name": "Group2"}, {"element_id": "2", "label": "Age", "name": "42"}, {"element_id": "3", "label": "City", "name": "Springfield"}, {"element_id": "8", "label": "Name"}, {"element_id": "9", "label": "Race"}], "edges": [{"label": "R", "element_id": "0", "start": "0", "end": "2"}, {"label": "R", "element_id": "1", "start": "0", "end": "3"}, {"label": "R", "element_id": "2", "start": "0", "end": "8"}, {"label": "R", "element_id": "3", "start": "0", "end": "9"}, {"label": "R", "element_id": "8", "start": "1", "end": "2"}, {"label": "R", "element_id": "9", "start": "1", "end": "3"}, {"label": "R", "element_id": "10", "start": "1", "end": "8"}, {"label": "R", "element_id": "11", "start": "1", "end": "9"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}], "table": [[1, 4], [2, 5], [3, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "5", "label": "Group", "name": "Group A"}, {"element_id": "6", "label": "Group", "name": "Group B"}, {"element_id": "7", "label": "Age", "name": "20-30"}, {"element_id": "8", "label": "City", "name": "New York"}, {"element_id": "9", "label": "City", "name": "LA"}], "edges": [{"label": "R", "element_id": "3", "start": "5", "end": "9"}, {"label": "R", "element_id": "4", "start": "6", "end": "8"}, {"label": "R", "element_id": "5", "start": "6", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}], "table": [[1], [2], [3]]}>>))


(check-synth)
                