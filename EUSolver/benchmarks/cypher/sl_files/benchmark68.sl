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
(NodeProperty String ("name" "companyName" "unitPrice" "shipCountry" "shipAddress" "productName" "city" "country"))
                    
; Edge Information
(EdgeLabels String ("PURCHASED" "SUPPLIES" "PART_OF" "ORDERS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n4" "n3" "n2" "n1" "n0"))
(EdgeVars String ("e3" "e2" "e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("200"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Category", "name": "Meat"}, {"element_id": "1", "label": "Category", "name": "Grains"}, {"element_id": "2", "label": "Customer", "country": "USA", "city": "Nantes", "name": "Janine Labrune"}, {"element_id": "6", "label": "Customer", "country": "uk", "city": "London", "name": "Elizabeth Brown"}, {"element_id": "7", "label": "Order", "shipCountry": "Venezuela", "shipAddress": "P.O. Box 555"}, {"element_id": "8", "label": "Order", "shipCountry": "Mexico", "shipAddress": "Avda. de la Constituci\u00f3n 2222"}, {"element_id": "9", "label": "Product", "unitPrice": 200, "productName": "Tourti\u00e8re"}, {"element_id": "10", "label": "Product", "unitPrice": 190, "productName": "Perth Pasties"}, {"element_id": "11", "label": "Product", "unitPrice": 400, "productName": "Gnocchi di nonna Alice"}, {"element_id": "12", "label": "Supplier", "country": "Singapore", "companyName": "Leka Trading"}, {"element_id": "13", "label": "Supplier", "country": "Italy", "companyName": "Pasta Buttini s.r.l."}, {"element_id": "14", "label": "Order", "shipCountry": "44000", "shipAddress": "67"}], "edges": [{"label": "PURCHASED", "element_id": "0", "start": "2", "end": "7"}, {"label": "ORDERS", "element_id": "1", "start": "7", "end": "9"}, {"label": "PART_OF", "element_id": "2", "start": "9", "end": "0"}, {"label": "SUPPLIES", "element_id": "3", "start": "12", "end": "9"}, {"label": "PURCHASED", "element_id": "4", "start": "6", "end": "8"}, {"label": "ORDERS", "element_id": "5", "start": "8", "end": "10"}, {"label": "PART_OF", "element_id": "12", "start": "10", "end": "0"}, {"label": "SUPPLIES", "element_id": "13", "start": "13", "end": "10"}, {"label": "SUPPLIES", "element_id": "14", "start": "13", "end": "11"}, {"label": "PART_OF", "element_id": "15", "start": "11", "end": "1"}, {"label": "PURCHASED", "element_id": "16", "start": "2", "end": "14"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "full"}], "table": [[1], [2], [3]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Category", "name": "Meat"}, {"element_id": "7", "label": "Category", "name": "Grains"}, {"element_id": "8", "label": "Customer", "country": "USA", "city": "San Fransico", "name": "Kenna Lin"}, {"element_id": "9", "label": "Order", "shipCountry": "Argentina", "shipAddress": "P.O. Box 57"}, {"element_id": "10", "label": "Order", "shipCountry": "UK", "shipAddress": "P.O. Box 577"}, {"element_id": "11", "label": "Product", "unitPrice": 350, "productName": "Tourtiere"}, {"element_id": "16", "label": "Product", "unitPrice": 200, "productName": "Perth Pasties"}, {"element_id": "17", "label": "Product", "unitPrice": 310, "productName": "Gnocchi di nonna Alice"}, {"element_id": "18", "label": "Supplier", "country": "Singapore", "companyName": "Leka"}, {"element_id": "19", "label": "Supplier", "country": "Italy", "companyName": "Pasta Buttini s.r.l."}, {"element_id": "20", "label": "Order", "shipCountry": "USA", "shipAddress": "89 Jefferson Way Suite 2"}], "edges": [{"label": "PURCHASED", "element_id": "5", "start": "8", "end": "9"}, {"label": "ORDERS", "element_id": "6", "start": "9", "end": "11"}, {"label": "PART_OF", "element_id": "7", "start": "11", "end": "6"}, {"label": "ORDERS", "element_id": "8", "start": "10", "end": "11"}, {"label": "SUPPLIES", "element_id": "9", "start": "18", "end": "11"}, {"label": "SUPPLIES", "element_id": "14", "start": "19", "end": "16"}, {"label": "PART_OF", "element_id": "15", "start": "16", "end": "7"}, {"label": "PART_OF", "element_id": "16", "start": "17", "end": "7"}, {"label": "ORDERS", "element_id": "17", "start": "10", "end": "16"}, {"label": "PURCHASED", "element_id": "18", "start": "8", "end": "20"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n18"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}], "table": [[1], [2], [3]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "11", "label": "Category", "name": "Meat"}, {"element_id": "12", "label": "Category", "name": "Grains"}, {"element_id": "13", "label": "Customer", "country": "Canada", "city": "Vancouver", "name": "Juan"}, {"element_id": "14", "label": "Customer", "country": "Scotland", "city": "Edinburgh", "name": "Elizabeth Lee"}, {"element_id": "15", "label": "Order", "shipCountry": "USA", "shipAddress": "P.O. Box 317"}, {"element_id": "16", "label": "Order", "shipCountry": "Canada", "shipAddress": "Avda. de la Constituci\u00f3n 2221"}, {"element_id": "17", "label": "Product", "unitPrice": 350, "productName": "Coconut Candy"}, {"element_id": "18", "label": "Product", "unitPrice": 199, "productName": "Pep Pasties"}, {"element_id": "19", "label": "Product", "unitPrice": 350, "productName": "Gnocchi di Gelato"}, {"element_id": "20", "label": "Supplier", "country": "Singapore", "companyName": "Leka Trading I.O"}, {"element_id": "21", "label": "Supplier", "country": "Singapore", "companyName": "Pasta"}, {"element_id": "22", "label": "Order", "shipCountry": "13008", "shipAddress": "12"}], "edges": [{"label": "PURCHASED", "element_id": "10", "start": "13", "end": "15"}, {"label": "ORDERS", "element_id": "11", "start": "15", "end": "17"}, {"label": "PART_OF", "element_id": "12", "start": "17", "end": "11"}, {"label": "SUPPLIES", "element_id": "13", "start": "20", "end": "17"}, {"label": "PURCHASED", "element_id": "14", "start": "14", "end": "16"}, {"label": "ORDERS", "element_id": "15", "start": "16", "end": "18"}, {"label": "PART_OF", "element_id": "16", "start": "18", "end": "11"}, {"label": "SUPPLIES", "element_id": "17", "start": "21", "end": "18"}, {"label": "SUPPLIES", "element_id": "18", "start": "21", "end": "19"}, {"label": "PART_OF", "element_id": "19", "start": "19", "end": "12"}, {"label": "PURCHASED", "element_id": "20", "start": "14", "end": "22"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n20"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}], "table": [[1], [2], [3]]}>>))


(check-synth)
                