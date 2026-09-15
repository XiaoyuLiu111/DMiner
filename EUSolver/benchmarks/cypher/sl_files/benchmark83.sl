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
(NodeProperty String ("year" "name" "country" "title"))
                    
; Edge Information
(EdgeLabels String ("PRODUCED"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("WaltDisney" "Universal Pictures" "2012" "2016" "2008"))

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


(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "9", "label": "Movie", "year": "2008", "title": "Tinker Bell"}, {"element_id": "10", "label": "Movie", "year": "2012", "title": "Brave"}, {"element_id": "11", "label": "Movie", "year": "2009", "title": "Earth"}], "edges": [{"label": "PRODUCED", "element_id": "6", "start": "8", "end": "9"}, {"label": "PRODUCED", "element_id": "7", "start": "8", "end": "11"}, {"label": "PRODUCED", "element_id": "8", "start": "8", "end": "10"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "title"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "7", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "8", "label": "ProductionCompany", "country": "UK", "name": "Eon Productions"}, {"element_id": "9", "label": "Movie", "year": "2012", "title": "Chimpanzee"}, {"element_id": "10", "label": "Movie", "year": "2012", "title": "Les Mis\u00e9rables"}, {"element_id": "11", "label": "Movie", "year": "2012", "title": "SkyFall"}, {"element_id": "12", "label": "Movie", "year": "2021", "title": "No Time to Die "}], "edges": [{"label": "PRODUCED", "element_id": "3", "start": "6", "end": "9"}, {"label": "PRODUCED", "element_id": "4", "start": "7", "end": "10"}, {"label": "PRODUCED", "element_id": "5", "start": "8", "end": "12"}, {"label": "PRODUCED", "element_id": "6", "start": "8", "end": "11"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "title"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "5", "label": "Movie", "year": "1998", "title": "Mulan"}, {"element_id": "6", "label": "Movie", "year": "2002", "title": "The Hunchback of Notre Dame II"}, {"element_id": "7", "label": "Movie", "year": "2015", "title": "Cinderella"}, {"element_id": "8", "label": "Movie", "year": "2007", "title": "Ratatouille"}, {"element_id": "9", "label": "Movie", "year": "2012", "title": "John Carter"}, {"element_id": "10", "label": "Movie", "year": "2008", "title": "High School Musical 3: Senior Year"}, {"element_id": "11", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "12", "label": "Movie", "year": "2016", "title": "The Great Wall"}], "edges": [{"label": "PRODUCED", "element_id": "3", "start": "4", "end": "5"}, {"label": "PRODUCED", "element_id": "4", "start": "4", "end": "6"}, {"label": "PRODUCED", "element_id": "5", "start": "4", "end": "7"}, {"label": "PRODUCED", "element_id": "6", "start": "4", "end": "8"}, {"label": "PRODUCED", "element_id": "7", "start": "4", "end": "9"}, {"label": "PRODUCED", "element_id": "8", "start": "4", "end": "10"}, {"label": "PRODUCED", "element_id": "9", "start": "11", "end": "12"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "title"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "1", "label": "Movie", "year": "2008", "title": "The Incredible Hulk"}, {"element_id": "2", "label": "Movie", "year": "2008", "title": "The Other Boleyn Girl"}, {"element_id": "3", "label": "Movie", "year": "2008", "title": "ABC"}, {"element_id": "4", "label": "ProductionCompany", "country": "", "name": "ABC Pictures"}], "edges": [{"label": "PRODUCED", "element_id": "0", "start": "0", "end": "1"}, {"label": "PRODUCED", "element_id": "1", "start": "0", "end": "2"}, {"label": "PRODUCED", "element_id": "2", "start": "4", "end": "3"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "title"}], "table": [[1, 3], [2, 4]]}>>))


(check-synth)
                