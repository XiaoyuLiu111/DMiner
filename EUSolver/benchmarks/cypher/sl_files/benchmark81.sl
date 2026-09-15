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
(NodeLabels String ("User" "Tweet"))
(NodeProperty String ("following" "name" "text" "favorites" "follwers" "created_at" "userID"))
                    
; Edge Information
(EdgeLabels String ("USING" "RETWEETS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Discover how financial institutions can use graph technology to meet their extensive data lineage challenges.… " "Right Relevance" "Avec le lancement d#AuraEnterprise" "0" "Billionaire" "Javaland 2021 – Was macht SRE eigentlich bei Neo4j Aura" "Philip Rathle" "@insideBigData features Neo4j's recently appointed VP of People, Kristin Thornby, in its latest news roundup" "2021-03-15T18:14:01Z" "1" "[Live Demo] Graph Algorithms Playground " "2021-03-16T04:02:01Z" "2021-03-16T14:21:01Z" "2021-03-16T00:10:00Z" "Boston Scientific" "2021-03-16T01:00:01Z"))

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


(constraint (= (f <<{"nodes": [{"element_id": "9", "label": "User", "following": 407, "follwers": 378, "name": "Billionaire", "userID": 1}, {"element_id": "10", "label": "User", "following": 51280, "name": "Right Relevance", "follwers": 51280, "userID": 2}, {"element_id": "11", "label": "Source", "name": "Buffer"}, {"element_id": "12", "label": "User", "following": 175, "name": "Boston Scientific", "follwers": 34407, "userID": 4063}, {"element_id": "13", "label": "Tweet", "favorites": 1, "created_at": "2021-03-15T18:14:01Z", "text": "Javaland 2021 \u2013 Was macht SRE eigentlich bei Neo4j Aura"}, {"element_id": "14", "label": "Tweet", "favorites": 0, "created_at": "2021-03-16T14:21:01Z", "text": "Avec le lancement d#AuraEnterprise"}, {"element_id": "15", "label": "Tweet", "favorites": 1, "created_at": "2021-03-16T04:02:01Z", "text": "Discover how financial institutions can use graph technology to meet their extensive data lineage challenges.\u2026 "}, {"element_id": "16", "label": "Tweet", "favorites": 0, "created_at": "2021-03-16T00:10:00Z", "text": "@insideBigData features Neo4j's recently appointed VP of People, Kristin Thornby, in its latest news roundup"}, {"element_id": "17", "label": "Tweet", "favorites": 2, "created_at": "2021-03-16T01:00:01Z", "text": "[Live Demo] Graph Algorithms Playground "}], "edges": [{"label": "USING", "element_id": "3", "start": "13", "end": "11"}, {"label": "RETWEETS", "element_id": "4", "start": "13", "end": "14"}, {"label": "RETWEETS", "element_id": "5", "start": "13", "end": "15"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "Source", "name": "Buffer"}, {"element_id": "9", "label": "Source", "name": "Twitter Web"}, {"element_id": "10", "label": "User", "following": 1124, "follwers": 1124, "name": "Philip Rathle", "userID": 1385}, {"element_id": "11", "label": "User", "following": 175, "name": "Boston Scientific", "follwers": 34407, "userID": 4063}, {"element_id": "12", "label": "Tweet", "favorites": 1, "created_at": "2021-03-15T18:14:01Z", "text": "Javaland 2021 \u2013 Was macht SRE eigentlich bei Neo4j Aura"}, {"element_id": "13", "label": "Tweet", "favorites": 0, "created_at": "2021-03-16T14:21:01Z", "text": "Avec le lancement d#AuraEnterprise"}, {"element_id": "14", "label": "Tweet", "favorites": 1, "created_at": "2021-03-16T04:02:01Z", "text": "Discover how financial institutions can use graph technology to meet their extensive data lineage challenges.\u2026 "}, {"element_id": "15", "label": "Tweet", "favorites": 0, "created_at": "2021-03-16T00:10:00Z", "text": "@insideBigData features Neo4j's recently appointed VP of People, Kristin Thornby, in its latest news roundup"}], "edges": [{"label": "USING", "element_id": "3", "start": "12", "end": "8"}, {"label": "RETWEETS", "element_id": "4", "start": "12", "end": "13"}, {"label": "USING", "element_id": "5", "start": "14", "end": "9"}, {"label": "RETWEETS", "element_id": "7", "start": "14", "end": "15"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}], "table": [[1, 3], [2, 4]]}>>))


(check-synth)
                