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
(NodeProperty String ("name" "born" "title" "tagline" "released"))
                    
; Edge Information
(EdgeLabels String ("ACTED_IN"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Tom Cruise"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Movie", "title": "Top Gun"}, {"element_id": "1", "label": "Person", "name": "Anthony Edwards"}, {"element_id": "2", "label": "Person", "name": "Tom Cruise"}, {"element_id": "3", "label": "Movie", "title": "Jerry Maguire"}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "1", "end": "0"}, {"label": "ACTED_IN", "element_id": "1", "start": "2", "end": "3"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "title"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Movie", "title": "Mission Impossible"}, {"element_id": "1", "label": "Person", "name": "Tom Cruise"}, {"element_id": "2", "label": "Movie", "title": "A Few Good Men"}, {"element_id": "3", "label": "Person", "name": "Tom Hanks"}, {"element_id": "8", "label": "Movie", "title": "Forrest Gump"}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "1", "end": "0"}, {"label": "ACTED_IN", "element_id": "1", "start": "1", "end": "2"}, {"label": "ACTED_IN", "element_id": "4", "start": "3", "end": "8"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "title"}], "table": [[1, 2]]}>>))


(check-synth)
                