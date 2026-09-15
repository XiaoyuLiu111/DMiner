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
(NodeProperty String ("tagline" "name" "title" "released" "born"))
                    
; Edge Information
(EdgeLabels String ("DIRECTED" "ACTED_IN"))
(EdgeProperty String ("roles"))

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Tom Hanks"))

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


(constraint (= (f <<{"nodes": [{"element_id": "10", "label": "Movie", "tagline": "Life is like a box of chocolates", "title": "Forrest Gump", "released": 1994}, {"element_id": "11", "label": "Movie", "tagline": "At the edge of the world, his journey begins", "title": "Cast Away", "released": 2000}, {"element_id": "12", "label": "Movie", "tagline": "The adventure takes off!", "title": "Toy Story", "released": 1995}, {"element_id": "13", "label": "Movie", "tagline": "The mission is a man", "title": "Saving Private Ryan", "released": 1998}, {"element_id": "14", "label": "Movie", "tagline": "Miracles happen", "title": "The Green Mile", "released": 1999}, {"element_id": "15", "label": "Person", "born": 1956, "name": "Tom Hanks"}, {"element_id": "16", "label": "Person", "born": 1951, "name": "Robert Zemeckis"}, {"element_id": "17", "label": "Person", "born": 1961, "name": "Bonnie Lynn Hunt"}, {"element_id": "18", "label": "Person", "born": 1966, "name": "Robin Wright"}, {"element_id": "19", "label": "Person", "born": 1952, "name": "Robert Zemeckis"}, {"element_id": "22", "label": "Person", "born": 1946, "name": "Steven Spielberg"}, {"element_id": "23", "label": "Person", "born": 1968, "name": "Edward Burns"}], "edges": [{"label": "ACTED_IN", "element_id": "4", "start": "15", "end": "10", "roles": "Forrest Gump"}, {"label": "ACTED_IN", "element_id": "5", "start": "18", "end": "10", "roles": "Jenny Curran"}, {"label": "DIRECTED", "element_id": "6", "start": "19", "end": "10"}, {"label": "ACTED_IN", "element_id": "7", "start": "15", "end": "11", "roles": "Chuck Noland"}, {"label": "ACTED_IN", "element_id": "13", "start": "15", "end": "14", "roles": "Paul Edgecomb"}, {"label": "ACTED_IN", "element_id": "14", "start": "17", "end": "14", "roles": "Jan Edgecomb"}, {"label": "ACTED_IN", "element_id": "15", "start": "15", "end": "13", "roles": "John H. Miller"}, {"label": "ACTED_IN", "element_id": "16", "start": "23", "end": "13", "roles": "Richard Reiben"}, {"label": "DIRECTED", "element_id": "17", "start": "22", "end": "13"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e4"], "property": "full"}], "table": [[1, 3, 5, 7], [9, 10, 11, 12], [2, 4, 6, 8]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "10", "label": "Movie", "tagline": "Life is like a box of chocolates", "title": "Forrest Gump", "released": 1994}, {"element_id": "11", "label": "Movie", "tagline": "At the edge of the world, his journey begins", "title": "Cast Away", "released": 2000}, {"element_id": "12", "label": "Movie", "tagline": "The adventure takes off!", "title": "Toy Story", "released": 1995}, {"element_id": "13", "label": "Movie", "tagline": "Out of the darkness... comes the Knight", "title": "The Dark Knight", "released": 2008}, {"element_id": "14", "label": "Movie", "tagline": "Miracles happen", "title": "The Green Mile", "released": 1999}, {"element_id": "15", "label": "Person", "born": 1956, "name": "Tom Hanks"}, {"element_id": "16", "label": "Person", "born": 1951, "name": "Robert Zemeckis"}, {"element_id": "17", "label": "Person", "born": 1956, "name": "Eric Roberts"}, {"element_id": "18", "label": "Person", "born": 1953, "name": "Tim Allen"}, {"element_id": "19", "label": "Person", "born": 1957, "name": "Michael Clarke Duncan"}], "edges": [{"label": "ACTED_IN", "element_id": "4", "start": "15", "end": "10", "roles": "Forrest Gump"}, {"label": "ACTED_IN", "element_id": "5", "start": "17", "end": "13", "roles": "Sal Maroni"}, {"label": "ACTED_IN", "element_id": "6", "start": "18", "end": "12", "roles": "Buzz Lightyear"}, {"label": "ACTED_IN", "element_id": "7", "start": "19", "end": "14", "roles": "John Coffey"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e4"], "property": "full"}], "table": [[1], [3], [2]]}>>))


(check-synth)
                