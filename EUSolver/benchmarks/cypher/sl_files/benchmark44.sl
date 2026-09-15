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
(NodeLabels String ("ProductionCompany" "Movie"))
(NodeProperty String ("name" "title" "year" "country"))
                    
; Edge Information
(EdgeLabels String ("PRODUCED"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("1996" "1997" "1998"))

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


(constraint (= (f <<{"nodes": [{"element_id": "14", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "15", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "16", "label": "Movie", "year": "2012", "title": "Frankenweenie"}, {"element_id": "17", "label": "Movie", "year": "2010", "title": "Robin Hood"}, {"element_id": "24", "label": "Movie", "year": "2011", "title": "Bridesmaids"}, {"element_id": "25", "label": "Movie", "year": "2019", "title": "How to Train Your Dragon The Hidden World"}, {"element_id": "26", "label": "Movie", "year": "2008", "title": "The Other Boleyn Girl"}, {"element_id": "27", "label": "Movie", "year": "2012", "title": "Anna Karenina"}], "edges": [{"label": "PRODUCED", "element_id": "15", "start": "14", "end": "16"}, {"label": "PRODUCED", "element_id": "16", "start": "15", "end": "17"}, {"label": "PRODUCED", "element_id": "17", "start": "15", "end": "24"}, {"label": "PRODUCED", "element_id": "18", "start": "15", "end": "25"}, {"label": "PRODUCED", "element_id": "19", "start": "15", "end": "26"}, {"label": "PRODUCED", "element_id": "20", "start": "15", "end": "27"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n24"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n25"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n26"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n27"], "property": "title"}], "table": [[1, 3, 5, 7, 9, 11], [2, 4, 6, 8, 10, 12]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Movie", "year": "1996", "title": "Muppet Treasure Island"}, {"element_id": "1", "label": "Movie", "year": "2009", "title": "Earth"}, {"element_id": "20", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "21", "label": "Movie", "year": "1998", "title": "Mulan"}, {"element_id": "22", "label": "Movie", "year": "1998", "title": "Beauty and the Beast"}, {"element_id": "23", "label": "Movie", "year": "1997", "title": "George of the Jungle"}, {"element_id": "24", "label": "Movie", "year": "1997", "title": "That Darn Cat"}, {"element_id": "25", "label": "Movie", "year": "1996", "title": "The Hunchback of Notre Dame"}, {"element_id": "26", "label": "Movie", "year": "1996", "title": "First Kid"}, {"element_id": "27", "label": "Movie", "year": "2008", "title": "Tinker Bell"}, {"element_id": "28", "label": "Movie", "year": "2011", "title": "Brave"}, {"element_id": "29", "label": "Movie", "year": "1996", "title": "101 Dalmatians"}], "edges": [{"label": "PRODUCED", "element_id": "15", "start": "20", "end": "21"}, {"label": "PRODUCED", "element_id": "16", "start": "20", "end": "22"}, {"label": "PRODUCED", "element_id": "17", "start": "20", "end": "23"}, {"label": "PRODUCED", "element_id": "18", "start": "20", "end": "24"}, {"label": "PRODUCED", "element_id": "19", "start": "20", "end": "25"}, {"label": "PRODUCED", "element_id": "20", "start": "20", "end": "26"}, {"label": "PRODUCED", "element_id": "21", "start": "20", "end": "27"}, {"label": "PRODUCED", "element_id": "22", "start": "20", "end": "28"}, {"label": "PRODUCED", "element_id": "23", "start": "20", "end": "29"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n20"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n27"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n20"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n28"], "property": "title"}], "table": [[1, 3], [2, 4]]}>>))


(check-synth)
                