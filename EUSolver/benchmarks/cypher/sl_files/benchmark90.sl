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
(NodeProperty String ("name" "born"))
                    
; Edge Information
(EdgeLabels String ())
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ())
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("1970" "1980"))

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


(constraint (= (f <<{"nodes": [{"element_id": "9", "label": "Person", "born": 1970, "name": "Gabriel Jarret"}, {"element_id": "10", "label": "Person", "born": 1980, "name": "Joanne Froggatt"}, {"element_id": "11", "label": "Person", "born": 1956, "name": "Tom Hanks"}, {"element_id": "12", "label": "Person", "born": 1976, "name": "Audrey Tautou"}, {"element_id": "13", "label": "Person", "born": 1972, "name": "Wil Wheaton"}, {"element_id": "14", "label": "Person", "born": 1946, "name": "Steven Spielberg"}, {"element_id": "15", "label": "Person", "born": 1966, "name": "Robin Wright"}, {"element_id": "16", "label": "Person", "born": 1985, "name": "Emile Hirsch"}, {"element_id": "17", "label": "Person", "born": 1982, "name": "Rain"}, {"element_id": "19", "label": "Person", "born": 1979, "name": "Rosamund Pike"}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "born"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "born"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "born"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n19"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n19"], "property": "born"}], "table": [[1, 3, 5, 7], [2, 4, 6, 8]]}>>))


(check-synth)
                