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
(NodeLabels String ("Store" "Item"))
(NodeProperty String ("price" "name"))
                    
; Edge Information
(EdgeLabels String ("Sells"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0" "n1"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ())

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((SUM AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Item", "price": 1500.0, "name": "Computer", "id": 1}, {"element_id": "7", "label": "Item", "price": 3500.0, "name": "Video_Game", "id": 2}, {"element_id": "8", "label": "Item", "price": 50.0, "name": "Book1", "id": 3}, {"element_id": "9", "label": "Item", "price": 20.0, "name": "Book2", "id": 4}, {"element_id": "10", "label": "Store", "name": "Store", "location": "Street R", "id": 5}, {"element_id": "11", "label": "Store", "name": "BookStore", "location": "Street Z", "id": 6}], "edges": [{"label": "Sells", "element_id": "4", "start": "10", "end": "6"}, {"label": "Sells", "element_id": "5", "start": "10", "end": "7"}, {"label": "Sells", "element_id": "6", "start": "11", "end": "8"}, {"label": "Sells", "element_id": "7", "start": "11", "end": "9"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"inputItems": ["n6", "n7"], "property": "price", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["n8", "n9"], "property": "price", "operator": "sum", "lhs": {}, "rhs": {}}], "table": [[1, 2], [3, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "9", "label": "Store", "name": "Store A", "location": "Downtown", "id": 1}, {"element_id": "10", "label": "Store", "name": "Store B", "location": "Midtown", "id": 2}, {"element_id": "11", "label": "Store", "name": "Store C", "location": "Uptown", "id": 3}, {"element_id": "12", "label": "Item", "price": 10.99, "name": "Item X", "id": 101}, {"element_id": "13", "label": "Item", "price": 15.49, "name": "Item Y", "id": 102}, {"element_id": "14", "label": "Item", "price": 7.25, "name": "Item Z", "id": 103}, {"element_id": "15", "label": "Item", "price": 5.99, "name": "Item W", "id": 104}, {"element_id": "16", "label": "Item", "price": 20.0, "name": "Item V", "id": 105}, {"element_id": "17", "label": "Item", "price": 13.75, "name": "Item U", "id": 106}], "edges": [{"label": "Sells", "element_id": "7", "start": "9", "end": "12"}, {"label": "Sells", "element_id": "8", "start": "10", "end": "13"}, {"label": "Sells", "element_id": "9", "start": "10", "end": "15"}, {"label": "Sells", "element_id": "10", "start": "10", "end": "16"}, {"label": "Sells", "element_id": "11", "start": "11", "end": "14"}, {"label": "Sells", "element_id": "12", "start": "11", "end": "17"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"inputItems": ["n12"], "property": "price", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["n13", "n15", "n16"], "property": "price", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["n14", "n17"], "property": "price", "operator": "sum", "lhs": {}, "rhs": {}}], "table": [[1, 2, 3], [4, 5, 6]]}>>))


(check-synth)
                