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
(NodeLabels String ("Person" "Movie"))
(NodeProperty String ("name" "nationality" "bornIn" "released" "title"))
                    
; Edge Information
(EdgeLabels String ())
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ())
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Keanu Reeves"))

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


(constraint (= (f <<{"nodes": [{"element_id": "2", "label": "Person", "bornIn": "Beirut", "nationality": "Canadian", "name": "Keanu Reeves"}, {"element_id": "3", "label": "Movie", "title": "Man of Tai Chi", "released": 2013}], "edges": [{"label": "ACTED_IN", "element_id": "2", "start": "2", "end": "3"}, {"label": "DIRECTED", "element_id": "3", "start": "2", "end": "3"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "nationality"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Person", "bornIn": "London", "nationality": "Canadian", "name": "Ryan Gosling"}, {"element_id": "5", "label": "Person", "bornIn": "Littlebeck", "nationality": "British", "name": "Joanne Froggatt"}, {"element_id": "6", "label": "Person", "bornIn": "Concord", "nationality": "American", "name": "Tom Hanks"}, {"element_id": "7", "label": "Person", "bornIn": "Beirut", "nationality": "Canadian", "name": "Keanu Reeves"}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "nationality"}], "table": [[1]]}>>))


(check-synth)
                