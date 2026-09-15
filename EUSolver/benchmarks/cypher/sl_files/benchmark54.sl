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
(NodeLabels String ("Product" "Order" "Category"))
(NodeProperty String ("shipPostalCode" "productID" "unitPrice" "categoryName" "shipAddress" "customerID" "shipVia" "productName" "categoryID" "shipCountry" "shipName" "shipCity" "supplierID"))
                    
; Edge Information
(EdgeLabels String ("PART_OF" "ORDERS"))
(EdgeProperty String ())

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


(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Order", "shipCity": "Oulu", "shipVia": 3, "customerID": "WARTH", "shipName": "Wartian Herkku", "shipPostalCode": "90110", "shipCountry": "Finland", "shipAddress": "Torikatu 38"}, {"element_id": "5", "label": "Customer", "country": "USA", "city": "Nantes", "name": "Janine Labrune"}, {"element_id": "6", "label": "Category", "name": "Meat"}, {"element_id": "7", "label": "Product", "supplierID": "21", "productID": "46", "productName": "Spegesild"}], "edges": [{"label": "ORDERS", "element_id": "3", "start": "4", "end": "7"}, {"label": "PURCHASED", "element_id": "4", "start": "5", "end": "4"}, {"label": "PART_OF", "element_id": "5", "start": "7", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "productName"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Order", "shipCity": "Seattle", "shipVia": 1, "customerID": "WHITC", "shipName": "White Clover Markets", "shipPostalCode": "98124", "shipCountry": "USA", "shipAddress": "1029-12th Ave. S."}, {"element_id": "5", "label": "Order", "shipCity": "Lander", "shipVia": 2, "customerID": "SPLIR", "shipName": "Split Rail Beer & Ale", "shipPostalCode": "82520", "shipCountry": "USA", "shipAddress": "P.O. Box 555"}, {"element_id": "6", "label": "Product", "supplierID": "21", "productID": "46", "productName": "Spegesild"}, {"element_id": "7", "label": "Product", "supplierID": "20", "productID": "47", "productName": "Snail"}], "edges": [{"label": "ORDERS", "element_id": "1", "start": "4", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "productName"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Order", "shipCity": "Seattle", "shipVia": 1, "customerID": "WHITC", "shipName": "White Clover Markets", "shipPostalCode": 98124, "shipCountry": "USA", "shipAddress": "1029-12th Ave. S."}, {"element_id": "1", "label": "Product", "unitPrice": 700, "supplierID": 21, "productID": 46, "productName": "Spegesild"}, {"element_id": "2", "label": "Category", "categoryName": "Seafood", "categoryID": 10}], "edges": [{"label": "ORDERS", "element_id": "0", "start": "0", "end": "1"}, {"label": "PART_OF", "element_id": "1", "start": "1", "end": "2"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "productName"}], "table": [[1]]}>>))

(check-synth)
                