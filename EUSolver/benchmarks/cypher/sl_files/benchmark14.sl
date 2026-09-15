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
(NodeLabels String ("Project" "Employee"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("charged_project"))
(EdgeProperty String ("hours"))

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ())

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((SUM AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "11", "label": "Project", "name": "P1"}, {"element_id": "12", "label": "Employee", "name": "Jeff"}, {"element_id": "13", "label": "Employee", "name": "Robyn"}, {"element_id": "14", "label": "Employee", "name": "Alice"}], "edges": [{"label": "charged_project", "element_id": "13", "start": "12", "end": "11", "hours": 10}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"inputItems": ["e13"], "property": "hours", "operator": "sum", "lhs": {}, "rhs": {}}], "table": [[1], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Employee", "name": "Bob"}, {"element_id": "1", "label": "Project", "name": "Project Alpha"}, {"element_id": "8", "label": "Employee", "name": "Alice"}, {"element_id": "9", "label": "Project", "name": "Project Beta"}], "edges": [{"label": "charged_project", "element_id": "0", "start": "0", "end": "1", "hours": 5}, {"label": "charged_project", "element_id": "5", "start": "8", "end": "1", "hours": 10}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}, {"inputItems": ["e0", "e5"], "property": "hours", "operator": "sum", "lhs": {}, "rhs": {}}], "table": [[1], [2]]}>>))


(check-synth)
                