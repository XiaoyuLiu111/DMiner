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
(NodeLabels String ("User"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("INTERACTS_WITH"))
(EdgeProperty String ())

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


(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "User", "name": "Neo4j"}, {"element_id": "7", "label": "User", "name": "Lju Lazarevic"}, {"element_id": "8", "label": "User", "name": "Tracy Oguni"}, {"element_id": "9", "label": "User", "name": "Kunal Gosrani"}, {"element_id": "10", "label": "User", "name": "Zeljko Predjeskovic"}, {"element_id": "11", "label": "User", "name": "NASA's Perseverance Mars Rover"}, {"element_id": "19", "label": "User", "name": "Jim Webber"}, {"element_id": "22", "label": "User", "name": "Michael Simons"}, {"element_id": "23", "label": "User", "name": "Michael Hunger"}], "edges": [{"label": "INTERACTS_WITH", "element_id": "7", "start": "22", "end": "23"}, {"label": "INTERACTS_WITH", "element_id": "11", "start": "23", "end": "8"}, {"label": "SIMILAR_TO", "element_id": "12", "start": "23", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n22"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n23"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n23"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}], "table": [[1, 3], [2, 4]]}>>))


(check-synth)
                