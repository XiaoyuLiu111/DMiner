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
(NodeLabels String ("BasketOne" "Apple" "BasketTwo"))
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("INCLUDE"))
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
(Aggregators String ((COUNT AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "3", "label": "Apple", "variety": "Gala"}, {"element_id": "4", "label": "BasketOne", "name": "Basket One"}, {"element_id": "5", "label": "BasketTwo", "name": "Basket Two"}, {"element_id": "6", "label": "BasketThree", "name": "Basket Three"}, {"element_id": "7", "label": "BasketFive", "name": "Basket Five"}], "edges": [{"label": "INCLUDE", "element_id": "2", "start": "4", "end": "3"}, {"label": "INCLUDE", "element_id": "3", "start": "5", "end": "3"}, {"label": "OUTSIDE", "element_id": "4", "start": "3", "end": "6"}, {"label": "OUTSIDE", "element_id": "5", "start": "3", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "2", "label": "Apple", "variety": "Gala"}, {"element_id": "3", "label": "BasketOne", "name": "Basket One"}, {"element_id": "4", "label": "BasketTwo", "name": "Basket Two"}, {"element_id": "5", "label": "BasketThree", "name": "Basket Three"}, {"element_id": "6", "label": "BasketFive", "name": "Basket Five"}], "edges": [{"label": "INCLUDE", "element_id": "0", "start": "3", "end": "2"}, {"label": "INCLUDE", "element_id": "1", "start": "4", "end": "2"}, {"label": "OUTSIDE", "element_id": "2", "start": "3", "end": "5"}, {"label": "OUTSIDE", "element_id": "3", "start": "4", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}], "table": [[1]]}>>))


(check-synth)
                