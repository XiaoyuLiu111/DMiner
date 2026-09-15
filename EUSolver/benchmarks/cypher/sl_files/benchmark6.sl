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
(NodeLabels String ("Matrix" "Crew"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("KNOWS" "CODED_BY"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Neo"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Crew", "name": "Neo"}, {"element_id": "1", "label": "Crew", "name": "Morpheus"}, {"element_id": "2", "label": "Crew", "name": "Trinity"}, {"element_id": "3", "label": "Matrix", "name": "Cypher"}, {"element_id": "4", "label": "Matrix", "name": "Agent Smith"}, {"element_id": "5", "label": "Matrix", "name": "The Architect"}, {"element_id": "12", "label": "Crew", "name": "Tank"}, {"element_id": "13", "label": "Crew", "name": "Oracle"}], "edges": [{"label": "CODED_BY", "element_id": "0", "start": "4", "end": "5"}, {"label": "KNOWS", "element_id": "10", "start": "0", "end": "1"}, {"label": "KNOWS", "element_id": "11", "start": "1", "end": "2"}, {"label": "KNOWS", "element_id": "12", "start": "1", "end": "3"}, {"label": "KNOWS", "element_id": "13", "start": "3", "end": "4"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Crew", "name": "Neo"}, {"element_id": "1", "label": "Crew", "name": "Morph"}, {"element_id": "2", "label": "Crew", "name": "Trinity"}, {"element_id": "9", "label": "Crew", "name": "Cypher"}, {"element_id": "10", "label": "Matrix", "name": "Agent Smith"}, {"element_id": "11", "label": "Matrix", "name": "The Architect"}, {"element_id": "20", "label": "Crew", "name": "White Rabbit"}, {"element_id": "21", "label": "Crew", "name": "Dozer"}, {"element_id": "22", "label": "Crew", "name": "Switch"}, {"element_id": "23", "label": "Matrix", "name": "Brown"}, {"element_id": "24", "label": "Matrix", "name": "Jones"}, {"element_id": "25", "label": "Crew", "name": "Tank"}, {"element_id": "26", "label": "Crew", "name": "Shaylae"}, {"element_id": "27", "label": "Crew", "name": "Oracle"}], "edges": [{"label": "KNOWS", "element_id": "4", "start": "0", "end": "1"}, {"label": "KNOWS", "element_id": "5", "start": "1", "end": "2"}, {"label": "KNOWS", "element_id": "6", "start": "9", "end": "10"}, {"label": "KNOWS", "element_id": "7", "start": "20", "end": "21"}, {"label": "KNOWS", "element_id": "15", "start": "21", "end": "22"}, {"label": "KNOWS", "element_id": "16", "start": "20", "end": "23"}, {"label": "KNOWS", "element_id": "17", "start": "23", "end": "24"}, {"label": "KNOWS", "element_id": "18", "start": "25", "end": "26"}, {"label": "KNOWS", "element_id": "19", "start": "26", "end": "27"}, {"label": "KNOWS", "element_id": "20", "start": "26", "end": "23"}, {"label": "KNOWS", "element_id": "21", "start": "23", "end": "24"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Crew", "name": "Neo"}, {"element_id": "1", "label": "Crew", "name": "Morph"}, {"element_id": "2", "label": "Crew", "name": "Trinity"}, {"element_id": "3", "label": "Crew", "name": "Cypher"}, {"element_id": "4", "label": "Matrix", "name": "Agent Smith"}, {"element_id": "5", "label": "Matrix", "name": "The Architect"}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1"}, {"label": "KNOWS", "element_id": "1", "start": "1", "end": "3"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}], "table": [[1]]}>>))


(check-synth)
                