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
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("RT_MENTIONS" "FOLLOWS" "INTERACT_WITH"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e0" "e1"))
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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "name": "Neo4j"}, {"element_id": "1", "label": "User", "name": "Angular"}, {"element_id": "2", "label": "User", "name": "Sebastian Daschner"}, {"element_id": "3", "label": "User", "name": "InfoWorld"}, {"element_id": "4", "label": "User", "name": "Luanne Misquitta"}, {"element_id": "5", "label": "User", "name": "QuarkusIO"}, {"element_id": "6", "label": "User", "name": "GraphAware"}, {"element_id": "7", "label": "User", "name": "Michael Simons"}, {"element_id": "8", "label": "User", "name": "Nicolas Mervaillie"}, {"element_id": "19", "label": "User", "name": "Stefan Kelle"}, {"element_id": "20", "label": "User", "name": "Matthias Haeussler"}], "edges": [{"label": "RT_MENTIONS", "element_id": "0", "start": "0", "end": "1"}, {"label": "FOLLOWS", "element_id": "1", "start": "0", "end": "2"}, {"label": "INTERACT_WITH", "element_id": "2", "start": "0", "end": "20"}, {"label": "RT_MENTIONS", "element_id": "3", "start": "0", "end": "3"}, {"label": "RT_MENTIONS", "element_id": "4", "start": "4", "end": "5"}, {"label": "RT_MENTIONS", "element_id": "5", "start": "4", "end": "6"}, {"label": "FOLLOWS", "element_id": "14", "start": "8", "end": "4"}, {"label": "FOLLOWS", "element_id": "15", "start": "19", "end": "4"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "name"}], "table": [[1, 3, 5, 7], [2, 4, 6, 8]]}>>))


(check-synth)
                