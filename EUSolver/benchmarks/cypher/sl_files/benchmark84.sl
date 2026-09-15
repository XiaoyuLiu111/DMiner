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
(NodeLabels String ("User" "Review" "Post"))
(NodeProperty String ("category" "location" "uid"))
                    
; Edge Information
(EdgeLabels String ("post" "review"))
(EdgeProperty String ("score"))

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("INSTA" "4" "5" "6" "8" "FB"))

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
                    NodeVars
                    ))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "uid": "999"}, {"element_id": "1", "label": "Review", "category": "INSTA"}, {"element_id": "2", "label": "Post", "location": "Seattle"}], "edges": [{"label": "post", "element_id": "0", "start": "2", "end": "0"}, {"label": "review", "element_id": "1", "start": "2", "end": "1", "score": 6}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "location"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "User", "uid": "132"}, {"element_id": "7", "label": "Review", "category": "INSTA"}, {"element_id": "8", "label": "User", "uid": "999"}, {"element_id": "9", "label": "Review", "category": "INSTA"}, {"element_id": "10", "label": "Post", "location": "Seattle"}, {"element_id": "11", "label": "Post", "location": "Seattle"}], "edges": [{"label": "post", "element_id": "4", "start": "10", "end": "6"}, {"label": "review", "element_id": "5", "start": "10", "end": "7", "score": 8}, {"label": "post", "element_id": "6", "start": "11", "end": "8"}, {"label": "review", "element_id": "7", "start": "11", "end": "9", "score": 8}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "location"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "uid": "156"}, {"element_id": "1", "label": "Review", "category": "FB"}, {"element_id": "2", "label": "User", "uid": "999"}, {"element_id": "3", "label": "Review", "category": "FB"}, {"element_id": "4", "label": "Post", "location": "Seattle"}, {"element_id": "5", "label": "Post", "location": "Seattle"}], "edges": [{"label": "post", "element_id": "0", "start": "4", "end": "0"}, {"label": "review", "element_id": "1", "start": "4", "end": "1", "score": 4}, {"label": "post", "element_id": "2", "start": "5", "end": "2"}, {"label": "review", "element_id": "3", "start": "5", "end": "3", "score": 5}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "location"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "9", "label": "User", "uid": "999"}, {"element_id": "10", "label": "User", "uid": "999"}, {"element_id": "11", "label": "User", "uid": "999"}, {"element_id": "12", "label": "Review", "category": "FB"}, {"element_id": "13", "label": "Review", "category": "INSTA"}, {"element_id": "14", "label": "Review", "category": "X"}, {"element_id": "15", "label": "Post", "location": "Seattle"}, {"element_id": "16", "label": "Post", "location": "Seattle"}, {"element_id": "17", "label": "Post", "location": "Seattle"}], "edges": [{"label": "post", "element_id": "6", "start": "15", "end": "9"}, {"label": "review", "element_id": "7", "start": "15", "end": "12", "score": 4}, {"label": "post", "element_id": "8", "start": "16", "end": "10"}, {"label": "review", "element_id": "9", "start": "16", "end": "14", "score": 6}, {"label": "post", "element_id": "10", "start": "17", "end": "11"}, {"label": "review", "element_id": "11", "start": "17", "end": "13", "score": 5}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "location"}], "table": [[1]]}>>))


(check-synth)
                