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
(Values String ("WaltDisney" "2012"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "1", "label": "Movie", "year": "1998", "title": "Mulan"}, {"element_id": "2", "label": "Movie", "year": "2015", "title": "Tomorrowland"}, {"element_id": "3", "label": "Movie", "year": "1997", "title": "George of the Jungle"}, {"element_id": "4", "label": "Movie", "year": "2007", "title": "Ratatouille"}, {"element_id": "16", "label": "Movie", "year": "2012", "title": "Wreck-It Ralph"}, {"element_id": "17", "label": "Movie", "year": "2008", "title": "High School Musical 3: Senior Year"}, {"element_id": "18", "label": "Movie", "year": "2008", "title": "Tinker Bell"}, {"element_id": "20", "label": "Movie", "year": "2011", "title": "Brave"}, {"element_id": "21", "label": "Movie", "year": "2009", "title": "Earth"}, {"element_id": "22", "label": "Movie", "year": "2010", "title": "Alice in Wonderland"}, {"element_id": "23", "label": "Movie", "year": "2020", "title": "Hamilton"}], "edges": [{"label": "PRODUCED", "element_id": "0", "start": "0", "end": "1"}, {"label": "PRODUCED", "element_id": "10", "start": "0", "end": "2"}, {"label": "PRODUCED", "element_id": "11", "start": "0", "end": "3"}, {"label": "PRODUCED", "element_id": "12", "start": "0", "end": "4"}, {"label": "PRODUCED", "element_id": "13", "start": "0", "end": "16"}, {"label": "PRODUCED", "element_id": "14", "start": "0", "end": "17"}, {"label": "PRODUCED", "element_id": "15", "start": "0", "end": "18"}, {"label": "PRODUCED", "element_id": "16", "start": "0", "end": "21"}, {"label": "PRODUCED", "element_id": "17", "start": "0", "end": "20"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "title"}], "table": [[1], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "1", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "2", "label": "Movie", "year": "2012", "title": "Frankenweenie"}, {"element_id": "7", "label": "Movie", "year": "2012", "title": "Westgate Tango"}, {"element_id": "8", "label": "Movie", "year": "2011", "title": "Bridesmaids"}, {"element_id": "9", "label": "Movie", "year": "2008", "title": "The Incredible Hulk"}, {"element_id": "10", "label": "Movie", "year": "2008", "title": "The Other Boleyn Girl"}, {"element_id": "11", "label": "Movie", "year": "2012", "title": "Anna Karenina"}, {"element_id": "16", "label": "Movie", "year": "2012", "title": "The Hobbit: An Unexpected Journey"}, {"element_id": "17", "label": "ProductionCompany", "country": "USA", "name": "MGM Studios"}], "edges": [{"label": "PRODUCED", "element_id": "0", "start": "0", "end": "2"}, {"label": "PRODUCED", "element_id": "1", "start": "1", "end": "7"}, {"label": "PRODUCED", "element_id": "2", "start": "1", "end": "8"}, {"label": "PRODUCED", "element_id": "4", "start": "1", "end": "9"}, {"label": "PRODUCED", "element_id": "5", "start": "1", "end": "10"}, {"label": "PRODUCED", "element_id": "6", "start": "1", "end": "11"}, {"label": "PRODUCED", "element_id": "12", "start": "17", "end": "16"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "title"}], "table": [[1], [2]]}>>))


(check-synth)
                