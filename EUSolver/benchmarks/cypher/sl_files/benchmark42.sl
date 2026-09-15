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
(NodeProperty String ("name" "born" "release" "title" "tagline"))
                    
; Edge Information
(EdgeLabels String ("WROTE" "ACTED_IN"))
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


(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Person", "born": 1961, "name": "Aaron Sorkin"}, {"element_id": "7", "label": "Movie", "release": 1992, "tagline": "In the heart of the nation's capital, in a courthouse of the U.S. government, one man will stop at nothing to keep his honor, and one will stop at nothing to find the truth.", "title": "A Few Good Men"}, {"element_id": "8", "label": "Movie", "release": 2000, "tagline": "The rest of his life begins now.", "title": "Jerry Maguire"}, {"element_id": "9", "label": "Person", "born": 1967, "name": "James Marshall"}, {"element_id": "10", "label": "Person", "born": 1957, "name": "Cameron Crowe"}, {"element_id": "11", "label": "Movie", "release": 1986, "tagline": "I feel the need, the need for speed.", "title": "Top Gun"}], "edges": [{"label": "WROTE", "element_id": "3", "start": "6", "end": "7"}, {"label": "ACTED_IN", "element_id": "4", "start": "9", "end": "8"}, {"label": "ACTED_IN", "element_id": "5", "start": "10", "end": "8"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "title"}], "table": [[1], [2]]}>>))


(check-synth)
                