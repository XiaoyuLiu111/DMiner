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
(NodeLabels String ("Me" "User"))
(NodeProperty String ("following" "name" "follwers" "userID"))
                    
; Edge Information
(EdgeLabels String ("RT_MENTIONS" "FOLLOWS" "INTERACTS_WITH"))
(EdgeProperty String ("location"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Me", "following": 10124, "follwers": 34507, "name": "Neo4j"}, {"element_id": "1", "label": "User", "following": 51280, "name": "Right Relevance", "follwers": 51280}, {"element_id": "2", "label": "User", "following": 1124, "follwers": 1124, "name": "Philip Rathle"}, {"element_id": "3", "label": "User", "following": 175, "name": "Boston Scientific", "follwers": 34407}, {"element_id": "4", "label": "User", "following": 1568, "follwers": 1568, "name": "NetScience"}, {"element_id": "5", "label": "User", "following": 47, "follwers": 47, "name": "Stuart Laurie"}, {"element_id": "6", "label": "User", "following": 32, "follwers": 82, "name": "Billionaire"}], "edges": [{"label": "INTERACTS_WITH", "element_id": "0", "start": "2", "end": "3"}, {"label": "RT_MENTIONS", "element_id": "1", "start": "0", "end": "3"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "5", "label": "Me", "following": 10124, "follwers": 34507, "name": "Neo4j"}, {"element_id": "6", "label": "User", "following": 109, "follwers": 22, "name": "Monica L"}, {"element_id": "7", "label": "User", "following": 341, "follwers": 235, "name": "JChen"}, {"element_id": "8", "label": "User", "following": 137, "follwers": 125, "name": "Oliviaaa"}, {"element_id": "9", "label": "User", "following": 371, "follwers": 315, "name": "Doras.J."}, {"element_id": "10", "label": "User", "following": 36, "follwers": 57, "name": "Sarah"}, {"element_id": "11", "label": "User", "following": 163, "follwers": 37, "name": "Kendall K"}, {"element_id": "14", "label": "User", "following": 51280, "name": "Right Relevance", "follwers": 51280}, {"element_id": "16", "label": "User", "following": 51280, "name": "Right Relevance", "follwers": 51280}, {"element_id": "17", "label": "User", "following": 1124, "follwers": 1124, "name": "Philip Rathle"}], "edges": [{"label": "FOLLOWS", "element_id": "2", "start": "6", "end": "5"}, {"label": "RT_MENTIONS", "element_id": "3", "start": "5", "end": "7"}, {"label": "FOLLOWS", "element_id": "4", "start": "8", "end": "5"}, {"label": "FOLLOWS", "element_id": "5", "start": "9", "end": "5"}, {"label": "RT_MENTIONS", "element_id": "6", "start": "5", "end": "10"}, {"label": "RT_MENTIONS", "element_id": "7", "start": "11", "end": "14"}, {"label": "RT_MENTIONS", "element_id": "12", "start": "5", "end": "16"}, {"label": "RT_MENTIONS", "element_id": "13", "start": "5", "end": "17"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "name"}], "table": [[1, 2, 3, 4]]}>>))


(check-synth)
                