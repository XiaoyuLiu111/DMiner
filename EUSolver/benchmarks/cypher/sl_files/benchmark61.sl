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
(NodeLabels String ("Tweet" "Source"))
(NodeProperty String ("created_at" "name" "text"))
                    
; Edge Information
(EdgeLabels String ("USING"))
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


(constraint (= (f <<{"nodes": [{"element_id": "9", "label": "Tweet", "created_at": "2021-03-15T18:14:01Z", "text": "Javaland 2021 \u2013 Was macht SRE eigentlich bei Neo4j Aura"}, {"element_id": "10", "label": "Tweet", "created_at": "2021-03-16T14:21:01Z", "text": "Avec le lancement d#AuraEnterprise"}, {"element_id": "11", "label": "Tweet", "created_at": "2021-03-16T04:02:01Z", "text": "Discover how financial institutions can use graph technology to meet their extensive data lineage challenges.\u2026 "}, {"element_id": "12", "label": "Tweet", "created_at": "2021-03-16T00:10:00Z", "text": "@insideBigData features Neo4j s recently appointed VP of People, Kristin Thornby, in its latest news roundup"}, {"element_id": "13", "label": "Tweet", "created_at": "2021-03-16T01:00:01Z", "text": "[Live Demo] Graph Algorithms Playground "}, {"element_id": "14", "label": "Tweet", "created_at": "2021-02-23T17:45:51Z", "text": "RT @lyonwj: Tomorrow I ll be speaking at the @nimbella Serverless &amp(semicolon) APIs Conference about how to build and deploy scalable GraphQL APIs by\u2026 "}, {"element_id": "15", "label": "Tweet", "created_at": "2021-03-23T11:42:15Z", "text": "Join the graph DB camp in ..."}, {"element_id": "16", "label": "Tweet", "created_at": "2021-03-15T21:03:01Z", "text": "Discover how RLE International uses Neo4j in engineering for the automotive industry"}, {"element_id": "17", "label": "Tweet", "created_at": "2021-03-15T23:00:17Z", "text": "Machine Learning with Neo4j \u2013 UK"}, {"element_id": "18", "label": "Source", "name": "Twitter Web App"}, {"element_id": "19", "label": "Source", "name": "Sendible"}], "edges": [{"label": "USING", "element_id": "2", "start": "9", "end": "18"}, {"label": "USING", "element_id": "3", "start": "10", "end": "18"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "text"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n18"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "text"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n18"], "property": "name"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Tweet", "created_at": "2021-03-16T11:00:04Z", "text": "Produktdatenmanagement mit der Graphdatenbank Neo4j"}, {"element_id": "1", "label": "Tweet", "created_at": "2021-03-16T05:00:33Z", "text": "[Webinar] Graph Data Science with #Neo4j \u2013 Italy"}, {"element_id": "2", "label": "Tweet", "created_at": "2021-03-16T11:35:05Z", "text": "RT @rotnroll666: Neo4j Cypher-DSL 2021.1 released in time for tomorrows Spring Data 6.1.M5 Release:"}, {"element_id": "3", "label": "Tweet", "created_at": "2021-03-16T04:00:23Z", "text": "Mittwoch, 17. M\u00e4rz || 17:00 - 17:40 C\u2026"}, {"element_id": "4", "label": "Tweet", "created_at": "2021-03-16T10:41:00Z", "text": "our first live podcast, live on @twitch. We'll be discussing how we g\u2026"}, {"element_id": "5", "label": "Tweet", "created_at": "2021-03-14T05:01:28Z", "text": "Open data API of #Politikus provides data researchers and journalists data to investigate and analyse complicated r\u2026"}, {"element_id": "6", "label": "Tweet", "created_at": "2021-03-16T14:21:01Z", "text": "[Virtual Event] Connections: Graphs for Cybersecurity in APAC"}, {"element_id": "19", "label": "Tweet", "created_at": "2021-03-15T16:11:00Z", "text": "@Neo4j facilite l\u2019acc\u00e8s des #graphes dans le #cloud en r\u00e9duisant les obstacles\u2026 https://t.co/ueWRAYqTtW"}, {"element_id": "20", "label": "Tweet", "created_at": "2021-03-16T05:00:33Z", "text": "Register here:\u2026 https://t.co/IBADoePpiA"}, {"element_id": "21", "label": "Tweet", "created_at": "2021-03-13T23:11:48Z", "text": "@BenFerrum @smartecocity @net_science @dnds_ceu @egovacademy @mmbronstein @barabasi @neo4j Do you know about Helsin\u2026"}, {"element_id": "22", "label": "Tweet", "created_at": "2021-03-14T01:04:25Z", "text": "@mesirii @net_science @dnds_ceu @egovacademy @mmbronstein @barabasi @neo4j thanks Michael!"}, {"element_id": "23", "label": "Source", "name": "Twitter Web App"}, {"element_id": "24", "label": "Source", "name": "Twitter Web"}], "edges": [{"label": "USING", "element_id": "0", "start": "0", "end": "23"}, {"label": "USING", "element_id": "1", "start": "2", "end": "23"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "text"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n23"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "text"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n23"], "property": "name"}], "table": [[1, 3], [2, 4]]}>>))


(check-synth)
                