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
(NodeLabels String ("Person" "Crime" "Officer"))
(NodeProperty String ("name" "rank" "id" "last_outcome" "type" "date"))
                    
; Edge Information
(EdgeLabels String ("INVESTIGATED_BY" "KNOWS" "PARTY_TO"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n3" "n2" "n1" "n0"))
(EdgeVars String ("e2" "e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Sergeant"))

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((COUNT AggregatorsSub)))

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
(ReturnAtom String (Aggregators
                    Properties
                    EdgeVars
                    NodeVars
                    ))

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


(constraint (= (f <<{"nodes": [{"element_id": "8", "label": "Person", "name": "Anne Freeman", "id": "640"}, {"element_id": "9", "label": "Person", "name": "Amanda Robertson", "id": "630"}, {"element_id": "10", "label": "Crime", "date": "19/08/2017", "last_outcome": "Unable to prosecute suspect", "type": "Public order"}, {"element_id": "11", "label": "Officer", "name": "Lilian Dubbin", "rank": "Sergeant", "id": "1551"}, {"element_id": "12", "label": "Person", "name": "Pamela Gibson", "id": "50"}, {"element_id": "13", "label": "Person", "name": "Stephanie Hughes", "id": "47"}, {"element_id": "14", "label": "Crime", "date": "16/08/2017", "last_outcome": "Unable to prosecute suspect", "type": "Violence and sexual offences"}, {"element_id": "15", "label": "Officer", "name": "Eal Coulton", "rank": "Inspector", "id": "2110"}], "edges": [{"label": "KNOWS", "element_id": "6", "start": "8", "end": "9"}, {"label": "PARTY_TO", "element_id": "7", "start": "9", "end": "10"}, {"label": "INVESTIGATED_BY", "element_id": "8", "start": "10", "end": "11"}, {"label": "KNOWS", "element_id": "9", "start": "12", "end": "13"}, {"label": "PARTY_TO", "element_id": "10", "start": "13", "end": "14"}, {"label": "INVESTIGATED_BY", "element_id": "11", "start": "14", "end": "15"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "full"}, {"inputItems": ["n10"], "property": "full", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1], [2], [3], [4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Denise Brown", "id": "1155"}, {"element_id": "1", "label": "Person", "name": "Joan Flores", "id": "993"}, {"element_id": "2", "label": "Crime", "date": "1/08/2017", "last_outcome": "Investigation complete(semicolon) no suspect identified", "type": "Vehicle crime"}, {"element_id": "3", "label": "Officer", "name": "Jody Headech", "rank": "Sergeant", "id": "1718"}, {"element_id": "4", "label": "Person", "name": "Anne Kimberly", "id": "640"}, {"element_id": "5", "label": "Person", "name": "Craig Marshall", "id": "1088"}, {"element_id": "6", "label": "Crime", "date": "7/08/2017", "type": "Public order"}, {"element_id": "7", "label": "Officer", "name": "Rand Bunworth", "rank": "Staff Sergeant", "id": "2078"}, {"element_id": "8", "label": "Person", "name": "James Kim", "id": "171"}, {"element_id": "9", "label": "Crime", "date": "6/08/2017", "last_outcome": "Investigation complete(semicolon) no suspect identified", "type": "Vehicle crime"}, {"element_id": "20", "label": "Officer", "name": "Lenette Buddock", "rank": "Senior Sergeant", "id": "1723"}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1"}, {"label": "PARTY_TO", "element_id": "1", "start": "1", "end": "2"}, {"label": "INVESTIGATED_BY", "element_id": "2", "start": "2", "end": "3"}, {"label": "KNOWS", "element_id": "3", "start": "4", "end": "5"}, {"label": "PARTY_TO", "element_id": "4", "start": "5", "end": "6"}, {"label": "INVESTIGATED_BY", "element_id": "5", "start": "6", "end": "7"}, {"label": "PARTY_TO", "element_id": "6", "start": "8", "end": "9"}, {"label": "INVESTIGATED_BY", "element_id": "14", "start": "9", "end": "20"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"inputItems": ["n2"], "property": "full", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1], [2], [3], [4]]}>>))


(check-synth)
                