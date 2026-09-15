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
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("SIMILAR_TO" "INTERACTS_WITH"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n3" "n2" "n1" "n0"))
(EdgeVars String ("e2" "e1" "e0"))
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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "name": "Jim Webber"}, {"element_id": "1", "label": "User", "name": "Michael Simons"}, {"element_id": "2", "label": "User", "name": "Michael Hunger"}, {"element_id": "3", "label": "User", "name": "Neo4j"}, {"element_id": "4", "label": "User", "name": "Lju Lazarevic"}, {"element_id": "5", "label": "User", "name": "Tracy Oguni"}, {"element_id": "6", "label": "User", "name": "Kunal Gosrani"}, {"element_id": "7", "label": "User", "name": "Zeljko Predjeskovic"}, {"element_id": "8", "label": "User", "name": "NASA's Perseverance Mars Rover"}], "edges": [{"label": "INTERACTS_WITH", "element_id": "0", "start": "3", "end": "1"}, {"label": "INTERACTS_WITH", "element_id": "1", "start": "1", "end": "2"}, {"label": "INTERACTS_WITH", "element_id": "2", "start": "2", "end": "5"}, {"label": "SIMILAR_TO", "element_id": "3", "start": "2", "end": "4"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e2"], "property": "full"}], "table": [[1], [2], [3], [4], [5], [6], [7]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "name": "Jim Webber"}, {"element_id": "1", "label": "User", "name": "Michael Simons"}, {"element_id": "2", "label": "User", "name": "Michael Hunger"}, {"element_id": "3", "label": "User", "name": "Neo4j"}, {"element_id": "4", "label": "User", "name": "Lju Lazarevic"}, {"element_id": "5", "label": "User", "name": "Tracy Oguni"}, {"element_id": "6", "label": "User", "name": "Kunal Gosrani"}, {"element_id": "16", "label": "User", "name": "Zeljko Predjeskovic"}, {"element_id": "17", "label": "User", "name": "Kiefer Sutherland"}, {"element_id": "18", "label": "User", "name": "NASA's Perseverance Mars Rover"}, {"element_id": "22", "label": "User", "name": "Christopher Guest"}, {"element_id": "23", "label": "User", "name": "Aaron Sorkin"}], "edges": [{"label": "INTERACTS_WITH", "element_id": "3", "start": "1", "end": "2"}, {"label": "INTERACTS_WITH", "element_id": "4", "start": "2", "end": "3"}, {"label": "INTERACTS_WITH", "element_id": "5", "start": "4", "end": "5"}, {"label": "INTERACTS_WITH", "element_id": "6", "start": "5", "end": "6"}, {"label": "INTERACTS_WITH", "element_id": "7", "start": "5", "end": "18"}, {"label": "INTERACTS_WITH", "element_id": "8", "start": "5", "end": "23"}, {"label": "INTERACTS_WITH", "element_id": "9", "start": "0", "end": "16"}, {"label": "INTERACTS_WITH", "element_id": "10", "start": "16", "end": "17"}, {"label": "INTERACTS_WITH", "element_id": "17", "start": "17", "end": "22"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n22"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e9"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e10"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e17"], "property": "full"}], "table": [[1], [2], [3], [4], [5], [6], [7]]}>>))


(check-synth)
                