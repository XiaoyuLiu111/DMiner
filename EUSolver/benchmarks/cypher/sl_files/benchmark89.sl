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
(NodeLabels String ("Person"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("FOLLOWS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("James Thompson"))

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


(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Person", "name": "James Thompson"}, {"element_id": "7", "label": "Person", "name": "Jessica Thompson"}, {"element_id": "8", "label": "Person", "name": "Paul Blythe"}, {"element_id": "9", "label": "Person", "name": "Angela Scope"}, {"element_id": "10", "label": "Person", "name": "Angela Scope"}, {"element_id": "11", "label": "Person", "name": "Jessica Thompson"}], "edges": [{"label": "FOLLOWS", "element_id": "3", "start": "6", "end": "7"}, {"label": "FOLLOWS", "element_id": "4", "start": "8", "end": "9"}, {"label": "FOLLOWS", "element_id": "5", "start": "10", "end": "11"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}], "table": [[1], [2]]}>>))


(check-synth)
                