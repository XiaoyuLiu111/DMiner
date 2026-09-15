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
(NodeLabels String ("Person"))
(NodeProperty String ("email" "name"))
                    
; Edge Information
(EdgeLabels String ("KNOWS"))
(EdgeProperty String ("since"))

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("2000"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Andy"}, {"element_id": "1", "label": "Person", "name": "Timothy"}, {"element_id": "2", "label": "Person", "name": "Peter"}, {"element_id": "9", "label": "Person", "name": "Lisa"}, {"element_id": "10", "label": "Person", "name": "John"}, {"element_id": "11", "label": "Person", "name": "Susan"}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1", "since": 2012}, {"label": "KNOWS", "element_id": "1", "start": "0", "end": "2", "since": 1999}, {"label": "KNOWS", "element_id": "7", "start": "2", "end": "9", "since": 2001}, {"label": "KNOWS", "element_id": "8", "start": "9", "end": "10", "since": 2000}, {"label": "KNOWS", "element_id": "9", "start": "10", "end": "11", "since": 2021}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "amy"}, {"element_id": "1", "label": "Person", "name": "Timothy"}, {"element_id": "2", "label": "Person", "name": "Peter"}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "2", "since": 2004}, {"label": "KNOWS", "element_id": "1", "start": "2", "end": "1", "since": 1998}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}], "table": [[1]]}>>))


(check-synth)
                