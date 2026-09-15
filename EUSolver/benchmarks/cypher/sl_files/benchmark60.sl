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
(EdgeLabels String ("RETWEETS" "POSTS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
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


(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "User", "following": 407, "follwers": 378, "name": "Billionaire", "userID": 1}, {"element_id": "5", "label": "Tweet", "created_at": "2021-03-15T18:14:01Z", "text": "Javaland 2021 \u2013 Was macht SRE eigentlich bei Neo4j Aura"}, {"element_id": "6", "label": "Tweet", "created_at": "2021-03-16T14:21:01Z", "text": "Avec le lancement d#AuraEnterprise"}, {"element_id": "7", "label": "Tweet", "created_at": "2021-03-16T04:02:01Z", "text": "Discover how financial institutions can use graph technology to meet their extensive data lineage challenges.\u2026 "}], "edges": [{"label": "POSTS", "element_id": "3", "start": "4", "end": "5"}, {"label": "RETWEETS", "element_id": "4", "start": "5", "end": "6"}, {"label": "RETWEETS", "element_id": "5", "start": "5", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "text"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "text"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "7", "label": "User", "following": 407, "follwers": 378, "name": "Billionaire", "userID": 1}, {"element_id": "8", "label": "Tweet", "created_at": "2021-03-16T11:00:04Z", "text": "Produktdatenmanagement mit der Graphdatenbank Neo4j"}, {"element_id": "9", "label": "Tweet", "created_at": "2021-03-16T10:41:00Z", "text": "our first live podcast, live on @twitch. We'll be discussing how we g\u2026"}, {"element_id": "10", "label": "Tweet", "created_at": "2021-03-14T05:01:28Z", "text": "Open data API of #Politikus provides data researchers and journalists data to investigate and analyse complicated r\u2026"}, {"element_id": "11", "label": "Tweet", "created_at": "2021-03-16T14:21:01Z", "text": "[Virtual Event] Connections: Graphs for Cybersecurity in APAC"}], "edges": [{"label": "POSTS", "element_id": "3", "start": "7", "end": "9"}, {"label": "RETWEETS", "element_id": "4", "start": "9", "end": "10"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "text"}], "table": [[1], [2]]}>>))


(check-synth)
                