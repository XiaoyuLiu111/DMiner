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
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("KNOWS" "WORKS_WITH" "FRIEND_OF"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Mark"))

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


(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "Person", "name": "Jack"}, {"element_id": "9", "label": "Person", "name": "Mike"}, {"element_id": "10", "label": "Person", "name": "Mark"}, {"element_id": "11", "label": "Person", "name": "Mark"}, {"element_id": "12", "label": "Person", "name": "Jake"}, {"element_id": "13", "label": "Person", "name": "Mikayla"}, {"element_id": "14", "label": "Person", "name": "Kim"}, {"element_id": "15", "label": "Person", "name": "Mark"}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}], "table": [[1, 2, 3]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Mark"}, {"element_id": "1", "label": "Person", "name": "Mark"}, {"element_id": "2", "label": "Person", "name": "Mark"}, {"element_id": "3", "label": "Person", "name": "Mark Smith"}, {"element_id": "4", "label": "Person", "name": "Marcus"}, {"element_id": "5", "label": "Person", "name": "Marc"}, {"element_id": "6", "label": "Person", "name": "Mark"}, {"element_id": "7", "label": "Person", "name": "Markus"}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1"}, {"label": "FRIEND_OF", "element_id": "1", "start": "0", "end": "2"}, {"label": "WORKS_WITH", "element_id": "2", "start": "2", "end": "3"}, {"label": "FRIEND_OF", "element_id": "3", "start": "3", "end": "4"}, {"label": "KNOWS", "element_id": "4", "start": "1", "end": "5"}, {"label": "WORKS_WITH", "element_id": "5", "start": "5", "end": "6"}, {"label": "KNOWS", "element_id": "6", "start": "6", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}], "table": [[1, 2, 3, 4]]}>>))


(check-synth)
                