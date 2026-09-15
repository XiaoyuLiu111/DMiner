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
(NodeLabels String ("wine_bottle" "wine_critic"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("REVIEW"))
(EdgeProperty String ("score"))

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
(Aggregators String ((MIN AggregatorsSub)
                     (MAX AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "wine_critic", "name": "Critic1"}, {"element_id": "1", "label": "wine_critic", "name": "Critic2"}, {"element_id": "2", "label": "wine_critic", "name": "Critic3"}, {"element_id": "3", "label": "wine_bottle", "name": "Bottle1"}, {"element_id": "4", "label": "wine_bottle", "name": "Bottle2"}, {"element_id": "5", "label": "wine_bottle", "name": "Bottle3"}, {"element_id": "6", "label": "wine_bottle", "name": "Bottle4"}, {"element_id": "7", "label": "wine_bottle", "name": "Bottle5"}], "edges": [{"label": "REVIEW", "element_id": "0", "start": "0", "end": "3", "score": 7}, {"label": "REVIEW", "element_id": "1", "start": "0", "end": "4", "score": 6}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"inputItems": ["e0"], "property": "score", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["e0"], "property": "score", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["e1"], "property": "score", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["e1"], "property": "score", "operator": "min", "lhs": {}, "rhs": {}}], "table": [[1, 2], [3, 4], [5, 7], [6, 8]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "wine_bottle", "name": "Chateau Margaux"}, {"element_id": "9", "label": "wine_bottle", "name": "Screaming Eagle"}, {"element_id": "10", "label": "wine_bottle", "name": "Opus One"}, {"element_id": "11", "label": "wine_bottle", "name": "Penfolds Grange"}, {"element_id": "12", "label": "wine_bottle", "name": "Domaine de la Romanee-Conti"}, {"element_id": "13", "label": "wine_critic", "name": "John Doe"}, {"element_id": "14", "label": "wine_critic", "name": "Jane Smith"}, {"element_id": "15", "label": "wine_critic", "name": "Robert Parker"}], "edges": [{"label": "REVIEW", "element_id": "0", "start": "13", "end": "8", "score": 95}, {"label": "REVIEW", "element_id": "1", "start": "13", "end": "9", "score": 90}, {"label": "REVIEW", "element_id": "2", "start": "14", "end": "10", "score": 93}, {"label": "REVIEW", "element_id": "3", "start": "15", "end": "12", "score": 99}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "name"}, {"inputItems": ["e0"], "property": "score", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["e0"], "property": "score", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["e1"], "property": "score", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["e1"], "property": "score", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["e2"], "property": "score", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["e2"], "property": "score", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["e3"], "property": "score", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["e3"], "property": "score", "operator": "min", "lhs": {}, "rhs": {}}], "table": [[1, 3, 5, 7], [2, 4, 6, 8], [9, 11, 13, 15], [10, 12, 14, 16]]}>>))


(check-synth)
                