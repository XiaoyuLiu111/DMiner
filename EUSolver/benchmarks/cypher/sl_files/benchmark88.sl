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
(NodeProperty String ("name" "born" "title"))
                    
; Edge Information
(EdgeLabels String ("ACTED_IN"))
(EdgeProperty String ("role"))

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Stand By Me"))

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


(constraint (= (f <<{"nodes": [{"element_id": "7", "label": "Person", "born": 1972, "name": "Wil Wheaton"}, {"element_id": "8", "label": "Movie", "title": "Stand By Me"}, {"element_id": "9", "label": "Person", "born": 1970, "name": "River Phoenix"}, {"element_id": "10", "label": "Person", "born": 1956, "name": "Tom Hanks"}, {"element_id": "11", "label": "Movie", "title": "Forrest Gump"}, {"element_id": "12", "label": "Person", "born": 1976, "name": "Audrey Tautou"}, {"element_id": "13", "label": "Movie", "title": "The Da Vinci Code"}], "edges": [{"label": "ACTED_IN", "element_id": "3", "start": "7", "end": "8", "role": "Gordie Lachance"}, {"label": "ACTED_IN", "element_id": "4", "start": "10", "end": "11", "role": "Forrest Gump"}, {"label": "ACTED_IN", "element_id": "5", "start": "12", "end": "13", "role": "Sophie Neveu"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "born": 1970, "name": "River Phoenix"}, {"element_id": "1", "label": "Movie", "title": "Stand By Me"}, {"element_id": "2", "label": "Person", "born": 1971, "name": "Corey Scott Feldman "}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "0", "end": "1", "role": "Chris Chambers"}, {"label": "ACTED_IN", "element_id": "1", "start": "2", "end": "1", "role": "Teddy Duchamp"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}], "table": [[1, 2]]}>>))


(check-synth)
                