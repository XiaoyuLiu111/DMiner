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
(NodeProperty String ("title" "name" "age"))
                    
; Edge Information
(EdgeLabels String ("KNOWS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
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


(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Person", "name": "Keanu Reeves", "age": 58}, {"element_id": "7", "label": "Person", "name": "Liam Neeson", "age": 70}, {"element_id": "8", "label": "Person", "name": "Carrie Anne Moss", "age": 58}, {"element_id": "9", "label": "Person", "name": "Guy Pearce", "age": 55}, {"element_id": "10", "label": "Person", "name": "Howard Deutch", "age": 27}, {"element_id": "11", "label": "Person", "name": "Kathryn Bigelow", "age": 71}, {"element_id": "13", "label": "Movie", "title": "Speed"}], "edges": [{"label": "KNOWS", "element_id": "3", "start": "6", "end": "8"}, {"label": "KNOWS", "element_id": "4", "start": "6", "end": "7"}, {"label": "KNOWS", "element_id": "5", "start": "6", "end": "11"}, {"label": "KNOWS", "element_id": "6", "start": "8", "end": "9"}, {"label": "KNOWS", "element_id": "7", "start": "7", "end": "10"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "age"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Keanu Reeves", "age": 58}, {"element_id": "1", "label": "Person", "name": "Angela Scope", "age": 37}, {"element_id": "2", "label": "Person", "name": "James Thompson", "age": 62}, {"element_id": "3", "label": "Movie", "title": "Speed"}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1"}, {"label": "KNOWS", "element_id": "1", "start": "0", "end": "2"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "age"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Keanu Reeves", "age": 58}, {"element_id": "1", "label": "Person", "name": "Jessica Thompson", "age": 37}, {"element_id": "2", "label": "Person", "name": "Guy Pearce", "age": 55}, {"element_id": "3", "label": "Person", "name": "Howard Deutch", "age": 27}, {"element_id": "4", "label": "Person", "name": "Orlando Jones", "age": 47}, {"element_id": "5", "label": "Person", "name": "Brooke Langton", "age": 31}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "4"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "age"}], "table": [[1], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Keanu Reeves", "age": 58}, {"element_id": "1", "label": "Person", "name": "Liam Neeson", "age": 70}, {"element_id": "2", "label": "Person", "name": "Carrie Anne Moss", "age": 55}, {"element_id": "3", "label": "Person", "name": "Guy Pearce", "age": 55}, {"element_id": "4", "label": "Person", "name": "Kathryn Bigelow", "age": 71}, {"element_id": "5", "label": "Movie", "title": "Speed"}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "0", "end": "5"}, {"label": "KNOWS", "element_id": "1", "start": "0", "end": "2"}, {"label": "KNOWS", "element_id": "2", "start": "0", "end": "1"}, {"label": "KNOWS", "element_id": "3", "start": "0", "end": "4"}, {"label": "KNOWS", "element_id": "4", "start": "2", "end": "3"}, {"label": "KNOWS", "element_id": "5", "start": "1", "end": "3"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "age"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))


(check-synth)
                