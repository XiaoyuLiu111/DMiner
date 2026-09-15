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
(Values String ("1999" "1997" "1998"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "1", "label": "Movie", "year": "1998", "title": "Mulan"}, {"element_id": "2", "label": "Movie", "year": "1998", "title": "Beauty and the Beast"}, {"element_id": "3", "label": "Movie", "year": "1997", "title": "George of the Jungle"}, {"element_id": "4", "label": "Movie", "year": "1997", "title": "That Darn Cat"}, {"element_id": "5", "label": "Movie", "year": "1999", "title": "The Straight Story"}, {"element_id": "6", "label": "Movie", "year": "1999", "title": "Tarzan"}, {"element_id": "14", "label": "Movie", "year": "2008", "title": "Tinker Bell"}, {"element_id": "15", "label": "Movie", "year": "2011", "title": "Brave"}, {"element_id": "17", "label": "Movie", "year": "2009", "title": "Earth"}, {"element_id": "18", "label": "Movie", "year": "2010", "title": "Alice in Wonderland"}, {"element_id": "19", "label": "Movie", "year": "2020", "title": "Hamilton"}], "edges": [{"label": "PRODUCED", "element_id": "0", "start": "0", "end": "1"}, {"label": "PRODUCED", "element_id": "1", "start": "0", "end": "2"}, {"label": "PRODUCED", "element_id": "2", "start": "0", "end": "3"}, {"label": "PRODUCED", "element_id": "3", "start": "0", "end": "4"}, {"label": "PRODUCED", "element_id": "4", "start": "0", "end": "5"}, {"label": "PRODUCED", "element_id": "5", "start": "0", "end": "6"}, {"label": "PRODUCED", "element_id": "6", "start": "0", "end": "14"}, {"label": "PRODUCED", "element_id": "13", "start": "0", "end": "17"}, {"label": "PRODUCED", "element_id": "14", "start": "0", "end": "15"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "title"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "7", "label": "ProductionCompany", "country": "USA", "name": "WaltDisney"}, {"element_id": "8", "label": "ProductionCompany", "country": "USA", "name": "Universal Pictures"}, {"element_id": "9", "label": "Movie", "year": "2012", "title": "Frankenweenie"}, {"element_id": "10", "label": "Movie", "year": "2010", "title": "Robin Hood"}, {"element_id": "11", "label": "Movie", "year": "2011", "title": "Bridesmaids"}, {"element_id": "12", "label": "Movie", "year": "2019", "title": "How to Train Your Dragon The Hidden World"}, {"element_id": "13", "label": "Movie", "year": "2008", "title": "The Other Boleyn Girl"}, {"element_id": "14", "label": "Movie", "year": "2012", "title": "Anna Karenina"}], "edges": [{"label": "PRODUCED", "element_id": "6", "start": "7", "end": "9"}, {"label": "PRODUCED", "element_id": "7", "start": "8", "end": "10"}, {"label": "PRODUCED", "element_id": "8", "start": "8", "end": "11"}, {"label": "PRODUCED", "element_id": "9", "start": "8", "end": "12"}, {"label": "PRODUCED", "element_id": "10", "start": "8", "end": "13"}, {"label": "PRODUCED", "element_id": "11", "start": "8", "end": "14"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "title"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "title"}], "table": [[1, 3, 5, 7, 9, 11], [2, 4, 6, 8, 10, 12]]}>>))


(check-synth)
                