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
(NodeLabels String ("Department" "Tutor" "Course"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("RESPONSIBLE_FOR" "WORKS_AT"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0" "n1" "n2"))
(EdgeVars String ("e0" "e1"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Maria Smith" "Science"))

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


(constraint (= (f <<{"nodes": [{"element_id": "3", "label": "Department", "name": "Science"}, {"element_id": "4", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "5", "label": "Course"}], "edges": [{"label": "WORKS_AT", "element_id": "2", "start": "4", "end": "3"}, {"label": "RESPONSIBLE_FOR", "element_id": "3", "start": "4", "end": "5"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e3"], "property": "full"}], "table": [[1], [3], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "2", "label": "Department", "name": "Science"}, {"element_id": "3", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "4", "label": "Course"}, {"element_id": "5", "label": "Department", "name": "Math"}, {"element_id": "6", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "7", "label": "Course"}, {"element_id": "8", "label": "Department", "name": "Physics"}, {"element_id": "9", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "10", "label": "Course"}, {"element_id": "11", "label": "Department", "name": "Chemistry"}, {"element_id": "12", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "13", "label": "Course"}, {"element_id": "14", "label": "Department", "name": "Science"}, {"element_id": "15", "label": "Tutor", "name": "Marlo"}, {"element_id": "16", "label": "Course"}, {"element_id": "17", "label": "Department", "name": "Science"}, {"element_id": "18", "label": "Tutor", "name": "Hailey"}, {"element_id": "19", "label": "Course"}, {"element_id": "39", "label": "Department", "name": "Science"}, {"element_id": "40", "label": "Tutor", "name": "Bob"}, {"element_id": "41", "label": "Course"}], "edges": [{"label": "WORKS_AT", "element_id": "1", "start": "3", "end": "2"}, {"label": "RESPONSIBLE_FOR", "element_id": "2", "start": "3", "end": "4"}, {"label": "WORKS_AT", "element_id": "3", "start": "6", "end": "5"}, {"label": "RESPONSIBLE_FOR", "element_id": "4", "start": "6", "end": "7"}, {"label": "WORKS_AT", "element_id": "5", "start": "9", "end": "8"}, {"label": "RESPONSIBLE_FOR", "element_id": "6", "start": "9", "end": "10"}, {"label": "WORKS_AT", "element_id": "7", "start": "12", "end": "11"}, {"label": "RESPONSIBLE_FOR", "element_id": "8", "start": "12", "end": "13"}, {"label": "WORKS_AT", "element_id": "9", "start": "15", "end": "14"}, {"label": "RESPONSIBLE_FOR", "element_id": "10", "start": "15", "end": "16"}, {"label": "WORKS_AT", "element_id": "11", "start": "18", "end": "17"}, {"label": "RESPONSIBLE_FOR", "element_id": "12", "start": "18", "end": "19"}, {"label": "WORKS_AT", "element_id": "26", "start": "40", "end": "39"}, {"label": "RESPONSIBLE_FOR", "element_id": "27", "start": "40", "end": "41"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e2"], "property": "full"}], "table": [[1], [3], [2]]}>>))


(check-synth)
                