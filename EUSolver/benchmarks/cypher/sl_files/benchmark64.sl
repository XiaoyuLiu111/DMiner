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
(NodeLabels String ("Tweet" "Hashtag" "Source" "Link" "Me" "User"))
(NodeProperty String ("following" "url" "name" "text" "favorites" "follwers" "created_at" "userID"))
                    
; Edge Information
(EdgeLabels String ("CONTAINS" "FOLLOWS" "TAGS" "USING" "POSTS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n5" "n4" "n3" "n2" "n1" "n0"))
(EdgeVars String ("e4" "e3" "e2" "e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Right Relevance" "url: https://twitter.com/i/web/status/1371325418947612679" "0" "https://twitter.com/i/web/status/1371325418947612679" "Billionaire" "Javaland 2021 – Was macht SRE eigentlich bei Neo4j Aura" "2021-03-15T17:07:01Z" "auraenterprise" "Discover how RLE International uses Neo4j in engineering for the automotive industry" "cloud" "2021-03-15T18:14:01Z" "Buffer" "1" "dsi" "https://twitter.com/i/web/status/1371476477267574785"))

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


(constraint (= (f <<{"nodes": [{"element_id": "9", "label": "Me", "following": 10124, "follwers": 34507, "name": "Neo4j"}, {"element_id": "10", "label": "User", "following": 51280, "name": "Right Relevance", "follwers": 51280, "userID": 2}, {"element_id": "11", "label": "Tweet", "favorites": 1, "created_at": "2021-03-15T18:14:01Z", "text": "Javaland 2021 \u2013 Was macht SRE eigentlich bei Neo4j Aura"}, {"element_id": "12", "label": "Tweet", "favorites": 2, "created_at": "2021-03-15T17:07:01Z", "text": "Discover how RLE International uses Neo4j in engineering for the automotive industry"}, {"element_id": "13", "label": "Link", "url": "https://twitter.com/i/web/status/1371325418947612679"}, {"element_id": "14", "label": "Hashtag", "name": "auraenterprise"}, {"element_id": "15", "label": "Link", "url": "https://twitter.com/i/web/status/1371476477267574785"}, {"element_id": "16", "label": "Hashtag", "name": "dsi"}, {"element_id": "17", "label": "Source", "name": "Buffer"}], "edges": [{"label": "FOLLOWS", "element_id": "9", "start": "9", "end": "10"}, {"label": "POSTS", "element_id": "10", "start": "10", "end": "11"}, {"label": "TAGS", "element_id": "11", "start": "11", "end": "14"}, {"label": "CONTAINS", "element_id": "12", "start": "11", "end": "13"}, {"label": "USING", "element_id": "13", "start": "11", "end": "17"}, {"label": "POSTS", "element_id": "14", "start": "10", "end": "12"}, {"label": "TAGS", "element_id": "15", "start": "12", "end": "16"}, {"label": "CONTAINS", "element_id": "16", "start": "12", "end": "15"}, {"label": "USING", "element_id": "17", "start": "12", "end": "17"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}], "table": [[1, 6], [2, 7], [3, 8], [4, 9], [5, 10]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Me", "following": 10124, "follwers": 34507, "name": "Neo4j"}, {"element_id": "1", "label": "User", "following": 51280, "name": "Right Relevance", "follwers": 51280, "userID": 2}, {"element_id": "2", "label": "Tweet", "favorites": 1, "created_at": "2021-03-15T18:14:01Z", "text": "Javaland 2021 \u2013 Was macht SRE eigentlich bei Neo4j Aura"}, {"element_id": "3", "label": "Link", "url": "url: https://twitter.com/i/web/status/1371325418947612679"}, {"element_id": "4", "label": "Hashtag", "name": "auraenterprise"}, {"element_id": "5", "label": "Hashtag", "name": "dsi"}, {"element_id": "6", "label": "Hashtag", "name": "cloud"}, {"element_id": "7", "label": "Source", "name": "Buffer"}], "edges": [{"label": "FOLLOWS", "element_id": "0", "start": "0", "end": "1"}, {"label": "POSTS", "element_id": "1", "start": "1", "end": "2"}, {"label": "TAGS", "element_id": "2", "start": "2", "end": "4"}, {"label": "CONTAINS", "element_id": "3", "start": "2", "end": "3"}, {"label": "TAGS", "element_id": "4", "start": "2", "end": "5"}, {"label": "TAGS", "element_id": "5", "start": "2", "end": "6"}, {"label": "USING", "element_id": "6", "start": "2", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}], "table": [[1, 6, 11], [2, 7, 12], [3, 8, 13], [4, 9, 14], [5, 10, 15]]}>>))


(check-synth)
                