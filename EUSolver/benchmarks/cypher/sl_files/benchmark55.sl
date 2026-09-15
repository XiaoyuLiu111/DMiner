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
(NodeLabels String ("Product" "Order"))
(NodeProperty String ("shipCountry" "productName"))
                    
; Edge Information
(EdgeLabels String ("ORDERS"))
(EdgeProperty String ("discount"))

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("0.35" "0.15"))

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


(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "Order", "shipCountry": "USA"}, {"element_id": "9", "label": "Order", "shipCountry": "Mexico"}, {"element_id": "10", "label": "Order", "shipCountry": "USA"}, {"element_id": "11", "label": "Order", "shipCountry": "Canada"}, {"element_id": "12", "label": "Product", "productName": "Spegesild"}, {"element_id": "13", "label": "Product", "productName": "Snail"}, {"element_id": "14", "label": "Product", "productName": "Keyboard"}, {"element_id": "15", "label": "Product", "productName": "Sugar"}], "edges": [{"label": "ORDERS", "element_id": "4", "start": "8", "end": "13", "discount": "0.5"}, {"label": "ORDERS", "element_id": "5", "start": "9", "end": "12", "discount": "0.15"}, {"label": "ORDERS", "element_id": "6", "start": "10", "end": "14", "discount": "0.25"}, {"label": "ORDERS", "element_id": "7", "start": "11", "end": "15", "discount": "0.35"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "productName"}], "table": [[1, 2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Order", "shipCountry": "USA"}, {"element_id": "1", "label": "Order", "shipCountry": "Mexico"}, {"element_id": "2", "label": "Order", "shipCountry": "China"}, {"element_id": "3", "label": "Order", "shipCountry": "Scottland"}, {"element_id": "4", "label": "Product", "productName": "Cookie"}, {"element_id": "5", "label": "Product", "productName": "Drawer"}, {"element_id": "13", "label": "Product", "productName": "Wood"}], "edges": [{"label": "ORDERS", "element_id": "0", "start": "2", "end": "4", "discount": "0.5"}, {"label": "ORDERS", "element_id": "6", "start": "0", "end": "5", "discount": "0.35"}, {"label": "ORDERS", "element_id": "7", "start": "1", "end": "13", "discount": "0.25"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "productName"}], "table": [[1, 2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Product", "productName": "Spegesild"}, {"element_id": "2", "label": "Order", "shipCountry": "Germany"}, {"element_id": "3", "label": "Product", "productName": "Clam Chowder"}], "edges": [{"label": "ORDERS", "element_id": "0", "start": "2", "end": "3", "discount": "0.25"}, {"label": "ORDERS", "element_id": "1", "start": "2", "end": "0", "discount": "0.2"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "productName"}], "table": [[1, 2]]}>>))


(check-synth)
                