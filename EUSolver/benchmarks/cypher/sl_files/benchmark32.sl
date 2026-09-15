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
(NodeLabels String ("Transaction" "Item" "Client"))
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("CONTAINS" "INCLUDES"))
(EdgeProperty String ("created"))

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("yesterday"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Client"}, {"element_id": "1", "label": "Transaction"}, {"element_id": "2", "label": "Transaction"}, {"element_id": "3", "label": "Transaction"}, {"element_id": "4", "label": "Transaction"}, {"element_id": "5", "label": "Transaction"}, {"element_id": "6", "label": "Item"}, {"element_id": "7", "label": "Item"}, {"element_id": "8", "label": "Item"}], "edges": [{"label": "CONTAINS", "element_id": "0", "start": "0", "end": "1", "created": "Wednesday"}, {"label": "CONTAINS", "element_id": "1", "start": "0", "end": "2", "created": "today"}, {"label": "CONTAINS", "element_id": "2", "start": "0", "end": "3", "created": "yesterday"}, {"label": "CONTAINS", "element_id": "3", "start": "0", "end": "4", "created": "today"}, {"label": "CONTAINS", "element_id": "4", "start": "0", "end": "5", "created": "today"}, {"label": "INCLUDES", "element_id": "5", "start": "1", "end": "6"}, {"label": "INCLUDES", "element_id": "6", "start": "3", "end": "8"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}], "table": [[1], [2], [3]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Client"}, {"element_id": "1", "label": "Transaction"}, {"element_id": "2", "label": "Item"}], "edges": [{"label": "CONTAINS", "element_id": "0", "start": "0", "end": "1", "created": "yesterday"}, {"label": "INCLUDES", "element_id": "1", "start": "1", "end": "2"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}], "table": [[1], [2], [3]]}>>))


(check-synth)
                