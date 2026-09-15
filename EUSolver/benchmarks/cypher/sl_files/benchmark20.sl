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
(NodeLabels String ("Node" "User"))
(NodeProperty String ("value"))
                    
; Edge Information
(EdgeLabels String ("relation"))
(EdgeProperty String ("uuid"))

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


(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "User"}, {"element_id": "5", "label": "Node", "value": 10}, {"element_id": "6", "label": "Node", "value": 4}, {"element_id": "7", "label": "Node", "value": 4}, {"element_id": "8", "label": "Node", "value": 100}, {"element_id": "19", "label": "User"}, {"element_id": "20", "label": "User"}, {"element_id": "21", "label": "User"}], "edges": [{"label": "relation", "element_id": "13", "start": "19", "end": "5", "uuid": 1}, {"label": "relation", "element_id": "14", "start": "20", "end": "6", "uuid": 2}, {"label": "relation", "element_id": "15", "start": "21", "end": "8", "uuid": 3}, {"label": "relation", "element_id": "16", "start": "21", "end": "5", "uuid": 3}, {"label": "relation", "element_id": "17", "start": "4", "end": "5", "uuid": 4}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e13"], "property": "uuid"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e14"], "property": "uuid"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e15", "e16"], "property": "uuid"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e17"], "property": "uuid"}, {"inputItems": ["n5"], "property": "value", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n5"], "property": "value", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["n6"], "property": "value", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n6"], "property": "value", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["n8", "n5"], "property": "value", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n8", "n5"], "property": "value", "operator": "min", "lhs": {}, "rhs": {}}, {"inputItems": ["n5"], "property": "value", "operator": "max", "lhs": {}, "rhs": {}}, {"inputItems": ["n5"], "property": "value", "operator": "min", "lhs": {}, "rhs": {}}], "table": [[1, 2, 3, 4], [5, 7, 9, 11], [6, 8, 10, 12]]}>>))


(check-synth)
                