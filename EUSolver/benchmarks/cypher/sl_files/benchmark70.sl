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
(NodeProperty String ("name" "establishYear" "title" "year" "country"))
                    
; Edge Information
(EdgeLabels String ("PRODUCED"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("1999" "WaltDisney" "2008"))

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


(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "5", "label": "Movie", "year": "1998", "title": "Mulan"}, {"element_id": "6", "label": "Movie", "year": "2015", "title": "Tomorrowland"}, {"element_id": "7", "label": "Movie", "year": "1997", "title": "George of the Jungle"}, {"element_id": "16", "label": "Movie", "year": "2007", "title": "Ratatouille"}, {"element_id": "17", "label": "Movie", "year": "1999", "title": "My Favorite Martian"}, {"element_id": "18", "label": "Movie", "year": "2008", "title": "High School Musical 3: Senior Year"}, {"element_id": "19", "label": "Movie", "year": "2008", "title": "Tinker Bell"}, {"element_id": "20", "label": "Movie", "year": "2012", "title": "Brave"}, {"element_id": "21", "label": "Movie", "year": "2009", "title": "Earth"}, {"element_id": "22", "label": "Movie", "year": "2010", "title": "Alice in Wonderland"}, {"element_id": "23", "label": "Movie", "year": "2020", "title": "Hamilton"}], "edges": [{"label": "PRODUCED", "element_id": "2", "start": "4", "end": "5"}, {"label": "PRODUCED", "element_id": "3", "start": "4", "end": "6"}, {"label": "PRODUCED", "element_id": "13", "start": "4", "end": "7"}, {"label": "PRODUCED", "element_id": "14", "start": "4", "end": "16"}, {"label": "PRODUCED", "element_id": "15", "start": "4", "end": "17"}, {"label": "PRODUCED", "element_id": "16", "start": "4", "end": "18"}, {"label": "PRODUCED", "element_id": "17", "start": "4", "end": "19"}, {"label": "PRODUCED", "element_id": "18", "start": "4", "end": "21"}, {"label": "PRODUCED", "element_id": "19", "start": "4", "end": "20"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n19"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n18"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "title"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "1", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "2", "label": "Movie", "year": "1999", "title": "Toy Story 2"}, {"element_id": "3", "label": "Movie", "year": "1999", "title": "The Mummy"}, {"element_id": "4", "label": "Movie", "year": "2012", "title": "Anna Karenina"}, {"element_id": "5", "label": "Movie", "year": "2008", "title": "The Incredible Hulk"}, {"element_id": "13", "label": "Movie", "year": "2008", "title": "The Other Boleyn Girl"}, {"element_id": "15", "label": "Movie", "year": "1999", "title": "Notting Hill"}], "edges": [{"label": "PRODUCED", "element_id": "0", "start": "0", "end": "2"}, {"label": "PRODUCED", "element_id": "1", "start": "1", "end": "3"}, {"label": "PRODUCED", "element_id": "2", "start": "1", "end": "4"}, {"label": "PRODUCED", "element_id": "3", "start": "1", "end": "5"}, {"label": "PRODUCED", "element_id": "9", "start": "1", "end": "13"}, {"label": "PRODUCED", "element_id": "11", "start": "1", "end": "15"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "title"}], "table": [[1], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "5", "label": "ProductionCompany", "country": "UK", "establishYear": 1961, "name": "Eon Productions"}, {"element_id": "6", "label": "Movie", "year": "1999", "title": "Toy Story 2"}, {"element_id": "7", "label": "Movie", "year": "2012", "title": "Quantum of Solace"}], "edges": [{"label": "PRODUCED", "element_id": "2", "start": "4", "end": "6"}, {"label": "PRODUCED", "element_id": "3", "start": "5", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "title"}], "table": [[1], [2]]}>>))


(check-synth)
                