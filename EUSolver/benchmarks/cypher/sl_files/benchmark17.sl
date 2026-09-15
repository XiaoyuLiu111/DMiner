(set-logic CYPHER)

; This is the framework for the grammar that can then just be "filled in" for each benchmark

(synth-fun f ((input Graph)) Graph

((Start Graph (Return))
(Input Graph (input))
(Return Graph ((return Clause ReturnList)))
(Clause Graph ((match Input PathPattern) (matchr Clause PathPattern)))
                    
; Patterns
(NodePattern String ((createNodePattern NodeVars NodeLabels)))
(EdgePattern String ((createEdgePattern EdgeVars EdgeLabels Direction)))
(Direction String ("->" "<-"))
(PathPattern String (NodePattern
                    (createPathPattern NodePattern EdgePattern PathPattern)))
                    
; Node Information 
(NodeLabels String ("User"))
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("FOLLOWS"))
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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "name": "Jim Webber"}, {"element_id": "1", "label": "User", "name": "Michael Simons"}, {"element_id": "10", "label": "User", "name": "Davy Suvee"}, {"element_id": "11", "label": "User", "name": "Neo4j"}, {"element_id": "12", "label": "User", "name": "GraphAware"}, {"element_id": "13", "label": "User", "name": "Excalidraw"}, {"element_id": "14", "label": "User", "name": "Kunal Gosrani"}, {"element_id": "15", "label": "User", "name": "Zeljko Predjeskovic"}, {"element_id": "17", "label": "User", "name": "NASA's Perseverance Mars Rover"}], "edges": [{"label": "FOLLOWS", "element_id": "0", "start": "10", "end": "11"}, {"label": "FOLLOWS", "element_id": "1", "start": "1", "end": "11"}, {"label": "FOLLOWS", "element_id": "2", "start": "11", "end": "12"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "name": "Christopher Guest"}, {"element_id": "1", "label": "User", "name": "Aaron Sorkin"}, {"element_id": "2", "label": "User", "name": "Laurence Fishburne"}, {"element_id": "3", "label": "User", "name": "Carrie-Anne Moss"}, {"element_id": "4", "label": "User", "name": "Kelly McGillis"}, {"element_id": "5", "label": "User", "name": "Rob Reiner"}, {"element_id": "6", "label": "User", "name": "Lana Wachowski"}, {"element_id": "16", "label": "User", "name": "Hugo Weaving"}, {"element_id": "17", "label": "User", "name": "Kiefer Sutherland"}], "edges": [{"label": "FOLLOWS", "element_id": "3", "start": "1", "end": "2"}, {"label": "FOLLOWS", "element_id": "4", "start": "4", "end": "5"}, {"label": "FOLLOWS", "element_id": "5", "start": "4", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))


(check-synth)
                