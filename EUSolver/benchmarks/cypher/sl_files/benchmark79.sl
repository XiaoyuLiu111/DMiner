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
(NodeLabels String ("Customer" "Supplier" "Product" "Category" "Order"))
(NodeProperty String ("name" "companyName" "shipPostalCode" "shipCountry" "shipCity" "shipAddress" "productName" "city" "shipName" "country"))
                    
; Edge Information
(EdgeLabels String ("PURCHASED" "SUPPLIES" "PART_OF" "ORDERS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n4" "n3" "n2" "n1" "n0"))
(EdgeVars String ("e3" "e2" "e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Italy"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Category", "name": "Meat"}, {"element_id": "1", "label": "Category", "name": "Grains"}, {"element_id": "2", "label": "Customer", "country": "USA", "city": "Nantes", "name": "Janine Labrune"}, {"element_id": "3", "label": "Customer", "country": "uk", "city": "London", "name": "Elizabeth Brown"}, {"element_id": "4", "label": "Order"}, {"element_id": "5", "label": "Order"}, {"element_id": "6", "label": "Product", "productName": "Tourti\u00e8re"}, {"element_id": "7", "label": "Product", "productName": "Perth Pasties"}, {"element_id": "16", "label": "Product", "productName": "Gnocchi di nonna Alice"}, {"element_id": "17", "label": "Supplier", "country": "Singapore", "companyName": "Leka Trading"}, {"element_id": "18", "label": "Supplier", "country": "Italy", "companyName": "Pasta Buttini s.r.l."}, {"element_id": "23", "label": "Order"}], "edges": [{"label": "PURCHASED", "element_id": "0", "start": "2", "end": "4"}, {"label": "ORDERS", "element_id": "1", "start": "4", "end": "6"}, {"label": "PART_OF", "element_id": "2", "start": "6", "end": "0"}, {"label": "SUPPLIES", "element_id": "3", "start": "18", "end": "6"}, {"label": "PURCHASED", "element_id": "4", "start": "3", "end": "5"}, {"label": "ORDERS", "element_id": "5", "start": "5", "end": "7"}, {"label": "PART_OF", "element_id": "6", "start": "7", "end": "0"}, {"label": "SUPPLIES", "element_id": "7", "start": "17", "end": "7"}, {"label": "SUPPLIES", "element_id": "16", "start": "17", "end": "16"}, {"label": "PART_OF", "element_id": "17", "start": "16", "end": "1"}, {"label": "PURCHASED", "element_id": "21", "start": "2", "end": "23"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n18"], "property": "companyName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "productName"}], "table": [[1], [2], [3], [4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Category", "name": "Meat"}, {"element_id": "1", "label": "Category", "name": "Grains"}, {"element_id": "2", "label": "Customer", "country": "USA", "city": "San Fransico", "name": "Kenna Lin"}, {"element_id": "3", "label": "Order"}, {"element_id": "4", "label": "Order"}, {"element_id": "5", "label": "Product", "productName": "Tourtiere"}, {"element_id": "16", "label": "Product", "productName": "Perth Pasties"}, {"element_id": "17", "label": "Product", "productName": "Gnocchi di nonna Alice"}, {"element_id": "18", "label": "Supplier", "country": "Korea", "companyName": "Leto"}, {"element_id": "19", "label": "Supplier", "country": "Italy", "companyName": "Pasta Buttini s.r.l."}, {"element_id": "21", "label": "Order"}], "edges": [{"label": "PURCHASED", "element_id": "0", "start": "2", "end": "3"}, {"label": "ORDERS", "element_id": "1", "start": "3", "end": "5"}, {"label": "PART_OF", "element_id": "2", "start": "5", "end": "0"}, {"label": "ORDERS", "element_id": "3", "start": "4", "end": "5"}, {"label": "SUPPLIES", "element_id": "4", "start": "19", "end": "5"}, {"label": "SUPPLIES", "element_id": "14", "start": "18", "end": "16"}, {"label": "PART_OF", "element_id": "15", "start": "16", "end": "1"}, {"label": "PART_OF", "element_id": "16", "start": "17", "end": "1"}, {"label": "ORDERS", "element_id": "17", "start": "4", "end": "16"}, {"label": "PURCHASED", "element_id": "19", "start": "2", "end": "21"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n19"], "property": "companyName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "productName"}], "table": [[1], [2], [3], [4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "11", "label": "Category", "name": "Meat"}, {"element_id": "12", "label": "Category", "name": "Grains"}, {"element_id": "13", "label": "Customer", "country": "Canada", "city": "Vancouver", "name": "Juan"}, {"element_id": "14", "label": "Customer", "country": "Scotland", "city": "Edinburgh", "name": "Elizabeth Lee"}, {"element_id": "15", "label": "Order"}, {"element_id": "16", "label": "Order"}, {"element_id": "17", "label": "Product", "productName": "Coconut Candy"}, {"element_id": "18", "label": "Product", "productName": "Pep Pasties"}, {"element_id": "19", "label": "Product", "productName": "Gnocchi di Gelato"}, {"element_id": "20", "label": "Supplier", "country": "Italy", "companyName": "PO"}, {"element_id": "21", "label": "Supplier", "country": "USA", "companyName": "BlackO"}, {"element_id": "23", "label": "Order"}], "edges": [{"label": "PURCHASED", "element_id": "10", "start": "13", "end": "15"}, {"label": "ORDERS", "element_id": "11", "start": "15", "end": "17"}, {"label": "PART_OF", "element_id": "12", "start": "17", "end": "11"}, {"label": "SUPPLIES", "element_id": "13", "start": "20", "end": "17"}, {"label": "PURCHASED", "element_id": "14", "start": "14", "end": "16"}, {"label": "ORDERS", "element_id": "15", "start": "16", "end": "18"}, {"label": "PART_OF", "element_id": "16", "start": "18", "end": "11"}, {"label": "SUPPLIES", "element_id": "17", "start": "21", "end": "18"}, {"label": "SUPPLIES", "element_id": "18", "start": "21", "end": "19"}, {"label": "PART_OF", "element_id": "19", "start": "19", "end": "12"}, {"label": "PURCHASED", "element_id": "21", "start": "14", "end": "23"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n20"], "property": "companyName"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "productName"}], "table": [[1], [2], [3], [4]]}>>))


(check-synth)
                