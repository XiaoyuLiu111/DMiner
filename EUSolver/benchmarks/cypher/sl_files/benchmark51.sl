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
(NodeLabels String ("movie"))
(NodeProperty String ("movie_id"))
                    
; Edge Information
(EdgeLabels String ())
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ())
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("1" "2" "3"))

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


(constraint (= (f <<{"nodes": [{"element_id": "10", "label": "movie", "movie_id": "1"}, {"element_id": "11", "label": "movie", "movie_id": "2"}, {"element_id": "12", "label": "movie", "movie_id": "3"}, {"element_id": "13", "label": "movie", "movie_id": "4"}, {"element_id": "14", "label": "movie", "movie_id": "5"}, {"element_id": "15", "label": "movie", "movie_id": "6"}, {"element_id": "16", "label": "movie", "movie_id": "7"}, {"element_id": "17", "label": "movie", "movie_id": "8"}, {"element_id": "18", "label": "movie", "movie_id": "9"}, {"element_id": "19", "label": "movie", "movie_id": "10"}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}], "table": [[1, 2, 3]]}>>))


(check-synth)
                