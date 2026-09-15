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
(Values String ("2008" "WaltDisney" "2012"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "1", "label": "Movie", "year": "1998", "title": "Mulan"}, {"element_id": "2", "label": "Movie", "year": "2002", "title": "The Hunchback of Notre Dame II"}, {"element_id": "3", "label": "Movie", "year": "2015", "title": "Cinderella"}, {"element_id": "4", "label": "Movie", "year": "2007", "title": "Ratatouille"}, {"element_id": "5", "label": "Movie", "year": "2012", "title": "John Carter"}, {"element_id": "12", "label": "Movie", "year": "2008", "title": "High School Musical 3: Senior Year"}, {"element_id": "13", "label": "Movie", "year": "2008", "title": "Tinker Bell"}, {"element_id": "16", "label": "Movie", "year": "2012", "title": "Brave"}, {"element_id": "17", "label": "Movie", "year": "2009", "title": "Earth"}, {"element_id": "18", "label": "Movie", "year": "2010", "title": "Alice in Wonderland"}, {"element_id": "19", "label": "Movie", "year": "2020", "title": "Hamilton"}], "edges": [{"label": "PRODUCED", "element_id": "0", "start": "0", "end": "1"}, {"label": "PRODUCED", "element_id": "1", "start": "0", "end": "2"}, {"label": "PRODUCED", "element_id": "2", "start": "0", "end": "3"}, {"label": "PRODUCED", "element_id": "3", "start": "0", "end": "4"}, {"label": "PRODUCED", "element_id": "4", "start": "0", "end": "5"}, {"label": "PRODUCED", "element_id": "7", "start": "0", "end": "12"}, {"label": "PRODUCED", "element_id": "8", "start": "0", "end": "13"}, {"label": "PRODUCED", "element_id": "9", "start": "0", "end": "17"}, {"label": "PRODUCED", "element_id": "13", "start": "0", "end": "16"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}], "table": [[1, 3, 5, 7], [2, 4, 6, 8]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "7", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "8", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "9", "label": "ProductionCompany", "country": "UK", "name": "Eon Productions"}, {"element_id": "10", "label": "Movie", "year": "2012", "title": "Chimpanzee"}, {"element_id": "11", "label": "Movie", "year": "2012", "title": "Les Mis\u00e9rables"}, {"element_id": "12", "label": "Movie", "year": "2012", "title": "SkyFall"}, {"element_id": "13", "label": "Movie", "year": "2008", "title": "Quantum of Solace"}, {"element_id": "15", "label": "Movie", "year": "2008", "title": "The Incredible Hulk"}, {"element_id": "16", "label": "Movie", "year": "2008", "title": "The Other Boleyn Girl"}], "edges": [{"label": "PRODUCED", "element_id": "5", "start": "7", "end": "10"}, {"label": "PRODUCED", "element_id": "6", "start": "8", "end": "11"}, {"label": "PRODUCED", "element_id": "7", "start": "8", "end": "15"}, {"label": "PRODUCED", "element_id": "8", "start": "8", "end": "16"}, {"label": "PRODUCED", "element_id": "9", "start": "9", "end": "12"}, {"label": "PRODUCED", "element_id": "10", "start": "9", "end": "13"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}], "table": [[1], [2]]}>>))


(check-synth)
                