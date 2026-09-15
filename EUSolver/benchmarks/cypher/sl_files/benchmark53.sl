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


(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "Order", "shipCity": "Seattle", "shipVia": 1, "customerID": "WHITC", "shipName": "White Clover Markets", "shipPostalCode": 98124, "shipCountry": "USA", "shipAddress": "1029-12th Ave. S."}, {"element_id": "9", "label": "Order", "shipCity": "M\u00e9xico D.F.", "shipVia": 3, "customerID": "ANATR", "shipName": "Ana Trujillo Emparedados y helados", "shipPostalCode": 5021, "shipCountry": "Mexico", "shipAddress": "Avda. de la Constituci\u00f3n 2222"}, {"element_id": "10", "label": "Order", "shipCity": "Lander", "shipVia": 2, "customerID": "SPLIR", "shipName": "Split Rail Beer & Ale", "shipPostalCode": 82520, "shipCountry": "USA", "shipAddress": "P.O. Box 555"}, {"element_id": "11", "label": "Order", "shipCity": "Lander", "shipVia": 1, "customerID": "LILAS", "shipName": "LILA-Supermercado", "shipPostalCode": 3508, "shipCountry": "Venezuela", "shipAddress": "P.O. Box 555"}, {"element_id": "12", "label": "Order", "shipCity": "Oulu", "shipVia": 3, "customerID": "WARTH", "shipName": "Wartian Herkku", "shipPostalCode": 90110, "shipCountry": "Finland", "shipAddress": "Torikatu 38"}, {"element_id": "13", "label": "Order", "shipCity": "Reims", "shipVia": 3, "customerID": "VINET", "shipName": "Vins et alcools Chevalier", "shipPostalCode": 51100, "shipCountry": "France", "shipAddress": "59 rue de l Abbaye"}, {"element_id": "14", "label": "Order", "shipCity": "Lander", "shipVia": 2, "customerID": "SPLIR", "shipName": "Split Rail Beer & Ale", "shipPostalCode": 82520, "shipCountry": "USA", "shipAddress": "P.O. Box 555"}, {"element_id": "15", "label": "Order", "shipCity": "Albuquerque", "shipVia": 2, "customerID": "RATTC", "shipName": "Rattlesnake Canyon Grocery", "shipPostalCode": 87110, "shipCountry": "USA", "shipAddress": "Milton Dr"}, {"element_id": "16", "label": "Order", "shipCity": "Cairo", "shipVia": 2, "customerID": "WELLI", "shipName": "Wellington Importadora", "shipPostalCode": 82520, "shipCountry": "Egypt", "shipAddress": "Rua do Mercado"}, {"element_id": "17", "label": "Product", "unitPrice": 700, "supplierID": 21, "productID": 46, "productName": "Spegesild"}, {"element_id": "18", "label": "Product", "unitPrice": 677, "supplierID": 20, "productID": 47, "productName": "Snail"}, {"element_id": "22", "label": "Category", "categoryName": "Seafood", "categoryID": 10}], "edges": [{"label": "ORDERS", "element_id": "0", "start": "12", "end": "17"}, {"label": "ORDERS", "element_id": "1", "start": "13", "end": "17"}, {"label": "ORDERS", "element_id": "2", "start": "14", "end": "17"}, {"label": "ORDERS", "element_id": "3", "start": "10", "end": "18"}, {"label": "PART_OF", "element_id": "4", "start": "17", "end": "22"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n22"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n22"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n22"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "productName"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Order", "shipCity": "Seattle", "shipVia": 1, "customerID": "WHITC", "shipName": "White Clover Markets", "shipPostalCode": 98124, "shipCountry": "USA", "shipAddress": "1029-12th Ave. S."}, {"element_id": "1", "label": "Order", "shipCity": "M\u00e9xico D.F.", "shipVia": 3, "customerID": "ANATR", "shipName": "Ana Trujillo Emparedados y helados", "shipPostalCode": 5021, "shipCountry": "Mexico", "shipAddress": "Avda. de la Constituci\u00f3n 2222"}, {"element_id": "2", "label": "Order", "shipCity": "Lander", "shipVia": 2, "customerID": "SPLIR", "shipName": "Split Rail Beer & Ale", "shipPostalCode": 82520, "shipCountry": "USA", "shipAddress": "P.O. Box 555"}, {"element_id": "3", "label": "Product", "unitPrice": 700, "supplierID": 21, "productID": 46, "productName": "Spegesild"}, {"element_id": "4", "label": "Category", "categoryName": "Seafood", "categoryID": 10}, {"element_id": "11", "label": "Category", "categoryName": "Food", "categoryID": 12}, {"element_id": "13", "label": "Category", "categoryName": "Prepared Food", "categoryID": 11}, {"element_id": "14", "label": "Category", "categoryName": "Seasoned Food", "categoryID": 13}], "edges": [{"label": "ORDERS", "element_id": "0", "start": "0", "end": "3"}, {"label": "PART_OF", "element_id": "1", "start": "3", "end": "4"}, {"label": "PART_OF", "element_id": "5", "start": "3", "end": "11"}, {"label": "PART_OF", "element_id": "7", "start": "3", "end": "13"}, {"label": "PART_OF", "element_id": "8", "start": "3", "end": "13"}, {"label": "PART_OF", "element_id": "9", "start": "3", "end": "14"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "productName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "categoryName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "productName"}], "table": [[1, 3, 5, 7, 9], [2, 4, 6, 8, 10]]}>>))


(check-synth)
                