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
(NodeLabels String ("Child" "Person" "Parent"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("BROTHER_OF" "MARRIED_TO" "HAS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Bob"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Brother"}, {"element_id": "1", "label": "Child", "name": "Son"}, {"element_id": "2", "label": "Child", "name": "Daughter"}, {"element_id": "8", "label": "Child", "name": "Daughter"}, {"element_id": "9", "label": "Child", "name": "Daughter"}, {"element_id": "10", "label": "Parent", "name": "Jessica"}, {"element_id": "16", "label": "Parent", "name": "Bob"}, {"element_id": "17", "label": "Parent", "name": "Alice"}], "edges": [{"label": "MARRIED_TO", "element_id": "12", "start": "16", "end": "17"}, {"label": "HAS", "element_id": "13", "start": "17", "end": "8"}, {"label": "HAS", "element_id": "14", "start": "16", "end": "1"}, {"label": "HAS", "element_id": "15", "start": "16", "end": "2"}, {"label": "HAS", "element_id": "16", "start": "10", "end": "9"}, {"label": "BROTHER_OF", "element_id": "17", "start": "16", "end": "0"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}], "table": [[1, 2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "5", "label": "Parent", "name": "Bob"}, {"element_id": "6", "label": "Parent", "name": "Susan"}, {"element_id": "7", "label": "Child", "name": "Son"}, {"element_id": "8", "label": "Child", "name": "Daughter"}, {"element_id": "9", "label": "Child", "name": "Daughter"}], "edges": [{"label": "HAS", "element_id": "3", "start": "5", "end": "8"}, {"label": "HAS", "element_id": "4", "start": "6", "end": "9"}, {"label": "HAS", "element_id": "5", "start": "6", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}], "table": [[1]]}>>))


(check-synth)
                