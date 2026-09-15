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
(NodeProperty String ("title" "name"))
                    
; Edge Information
(EdgeLabels String ("DIRECTED" "ACTED_IN"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Charlie Sheen"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Charlie Sheen"}, {"element_id": "1", "label": "Person", "name": "Martin Sheen"}, {"element_id": "2", "label": "Person", "name": "Michael Douglas"}, {"element_id": "3", "label": "Person", "name": "Oliver Stone"}, {"element_id": "4", "label": "Person", "name": "Rob Reiner"}, {"element_id": "5", "label": "Movie", "title": "Wall Street"}, {"element_id": "9", "label": "Movie", "title": "The American President"}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "0", "end": "5", "role": "Bud Fox"}, {"label": "DIRECTED", "element_id": "1", "start": "3", "end": "5"}, {"label": "ACTED_IN", "element_id": "2", "start": "1", "end": "9", "role": "A.J. MacInerney"}, {"label": "ACTED_IN", "element_id": "3", "start": "2", "end": "9", "role": "President Andrew Shepherd"}, {"label": "DIRECTED", "element_id": "4", "start": "4", "end": "9"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "title"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Charlie Sheen"}, {"element_id": "1", "label": "Person", "name": "Tom Hanks"}, {"element_id": "2", "label": "Person", "name": "Leonardo DiCaprio"}, {"element_id": "3", "label": "Movie", "title": "Major League"}, {"element_id": "4", "label": "Movie", "title": "Forrest Gump"}, {"element_id": "5", "label": "Movie", "title": "Titanic"}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "0", "end": "3", "role": "Bud"}, {"label": "ACTED_IN", "element_id": "1", "start": "1", "end": "4", "role": "Forrest Gump"}, {"label": "ACTED_IN", "element_id": "2", "start": "2", "end": "5", "role": "Jack Dawson"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "title"}], "table": [[1]]}>>))


(check-synth)
                