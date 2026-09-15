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
(NodeLabels String ("Student" "Course"))
(NodeProperty String ("firstname" "lastname" "name"))
                    
; Edge Information
(EdgeLabels String ("ENROLLEDIN"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ())

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Student", "firstname": "Kim", "lastname": "Lee"}, {"element_id": "1", "label": "Course", "name": "math"}, {"element_id": "2", "label": "Student", "firstname": "Katherine", "lastname": "Lee"}, {"element_id": "3", "label": "Student", "firstname": "Lucy", "lastname": "Tang"}, {"element_id": "4", "label": "Course", "name": "physics"}, {"element_id": "10", "label": "Student", "firstname": "Katherine", "lastname": "White"}], "edges": [{"label": "ENROLLEDIN", "element_id": "0", "start": "0", "end": "1"}, {"label": "ENROLLEDIN", "element_id": "1", "start": "2", "end": "1"}, {"label": "ENROLLEDIN", "element_id": "2", "start": "3", "end": "4"}, {"label": "ENROLLEDIN", "element_id": "3", "start": "10", "end": "4"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}], "table": [[1, 4], [2, 5], [3, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Student", "firstname": "Luke", "lastname": "Tang"}, {"element_id": "1", "label": "Course", "name": "chemistry"}, {"element_id": "2", "label": "Student", "firstname": "Matthew", "lastname": "Brown"}, {"element_id": "3", "label": "Student", "firstname": "James", "lastname": "Curren"}, {"element_id": "4", "label": "Course", "name": "history"}, {"element_id": "10", "label": "Student", "firstname": "Matt", "lastname": "Curren"}], "edges": [{"label": "ENROLLEDIN", "element_id": "0", "start": "0", "end": "1"}, {"label": "ENROLLEDIN", "element_id": "1", "start": "2", "end": "1"}, {"label": "ENROLLEDIN", "element_id": "2", "start": "3", "end": "4"}, {"label": "ENROLLEDIN", "element_id": "6", "start": "10", "end": "4"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "firstname"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}], "table": [[1, 4], [2, 5], [3, 6]]}>>))


(check-synth)
                