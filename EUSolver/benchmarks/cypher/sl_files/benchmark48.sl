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
(NodeLabels String ("Course" "Student"))
(NodeProperty String ("nb" "name" "coursename" "course_nb"))
                    
; Edge Information
(EdgeLabels String ("Follow"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0" "n1"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("1"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Student", "nb": "0", "name": "A"}, {"element_id": "1", "label": "Student", "nb": "1", "name": "B"}, {"element_id": "2", "label": "Student", "nb": "2", "name": "C"}, {"element_id": "3", "label": "Student", "nb": "3", "name": "D"}, {"element_id": "4", "label": "Student", "nb": "4", "name": "E"}, {"element_id": "5", "label": "Course", "coursename": "Cryptography", "course_nb": "1"}, {"element_id": "6", "label": "Course", "coursename": "Big Data", "course_nb": "2"}, {"element_id": "7", "label": "Course", "coursename": "Cloud", "course_nb": "3"}], "edges": [{"label": "Follow", "element_id": "4", "start": "1", "end": "5"}, {"label": "Follow", "element_id": "5", "start": "2", "end": "5"}, {"label": "Follow", "element_id": "6", "start": "3", "end": "5"}, {"label": "Follow", "element_id": "7", "start": "3", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "coursename"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "coursename"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "coursename"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "1", "label": "Student", "nb": "7", "name": "M"}, {"element_id": "2", "label": "Student", "nb": "8", "name": "N"}, {"element_id": "3", "label": "Student", "nb": "9", "name": "Z"}, {"element_id": "4", "label": "Course", "coursename": "System", "course_nb": "1"}, {"element_id": "5", "label": "Course", "coursename": "Algebra", "course_nb": "2"}, {"element_id": "6", "label": "Course", "coursename": "Verification", "course_nb": "3"}], "edges": [{"label": "Follow", "element_id": "3", "start": "1", "end": "4"}, {"label": "Follow", "element_id": "4", "start": "2", "end": "5"}, {"label": "Follow", "element_id": "5", "start": "3", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "coursename"}], "table": [[1], [2]]}>>))


(check-synth)
                