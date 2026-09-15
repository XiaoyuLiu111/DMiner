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
(NodeLabels String ("Student"))
(NodeProperty String ("class" "GPA"))
                    
; Edge Information
(EdgeLabels String ())
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ())
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Sophomore"))

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((AVG AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Student", "GPA": 3, "class": "Sophomore"}, {"element_id": "1", "label": "Student", "GPA": 3, "class": "Sophomore"}, {"element_id": "2", "label": "Student", "GPA": 3, "class": "Freshman"}, {"element_id": "3", "label": "Student", "GPA": 3, "class": "Sophomore"}, {"element_id": "4", "label": "Student", "GPA": 3, "class": "Junior"}, {"element_id": "5", "label": "Student", "GPA": 4, "class": "Sophomore"}, {"element_id": "6", "label": "Student", "GPA": 4, "class": "Senior"}], "edges": []}>>) 
                <<{"outputGraph": [{"inputItems": ["n0", "n1", "n3", "n5"], "property": "GPA", "operator": "avg", "lhs": {}, "rhs": {}}], "table": [[1]]}>>))


(check-synth)
                