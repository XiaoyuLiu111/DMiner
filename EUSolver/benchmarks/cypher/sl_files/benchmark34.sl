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
(NodeLabels String ("User" "Hobby"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("HAS_HOBBY"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Sport" "Music"))

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
(ReturnAtom String (Aggregators
                    Properties
                    EdgeVars
                    NodeVars
                    (esub ReturnAtom ReturnAtom)))

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


(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Hobby", "name": "Music"}, {"element_id": "5", "label": "Hobby", "name": "Sport"}, {"element_id": "6", "label": "Hobby", "name": "Running"}, {"element_id": "7", "label": "User", "name": "Max"}, {"element_id": "8", "label": "User", "name": "Brian"}], "edges": [{"label": "HAS_HOBBY", "element_id": "1", "start": "7", "end": "4"}, {"label": "HAS_HOBBY", "element_id": "2", "start": "8", "end": "5"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}], "table": [[1, 2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Hobby", "name": "Sport"}, {"element_id": "1", "label": "Hobby", "name": "Music"}, {"element_id": "2", "label": "User", "name": "Joe"}, {"element_id": "3", "label": "User", "name": "Billy"}, {"element_id": "4", "label": "Hobby", "name": "Hiking"}, {"element_id": "10", "label": "Hobby", "name": "Singing"}, {"element_id": "12", "label": "User", "name": "Tim"}, {"element_id": "13", "label": "Hobby", "name": "Painting"}, {"element_id": "14", "label": "User", "name": "Jerry"}, {"element_id": "18", "label": "User", "name": "Kate"}], "edges": [{"label": "HAS_HOBBY", "element_id": "0", "start": "2", "end": "0"}, {"label": "HAS_HOBBY", "element_id": "1", "start": "3", "end": "1"}, {"label": "HAS_HOBBY", "element_id": "2", "start": "12", "end": "4"}, {"label": "HAS_HOBBY", "element_id": "3", "start": "14", "end": "10"}, {"label": "HAS_HOBBY", "element_id": "8", "start": "18", "end": "13"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}], "table": [[1, 2]]}>>))


(check-synth)
                