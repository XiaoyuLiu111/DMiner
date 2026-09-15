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
(NodeLabels String ("Department" "Course" "Tutor"))
(NodeProperty String ("department" "name"))
                    
; Edge Information
(EdgeLabels String ("WORKS_AT" "RESPONSIBLE_FOR"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
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


(constraint (= (f <<{"nodes": [{"element_id": "11", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "12", "label": "Tutor", "name": "John Doe"}, {"element_id": "13", "label": "Tutor", "name": "Alice Johnson"}, {"element_id": "14", "label": "Tutor", "name": "Mark Brown"}, {"element_id": "15", "label": "Course", "name": "Biology 101"}, {"element_id": "16", "label": "Course", "name": "Physics 202"}, {"element_id": "17", "label": "Course", "name": "Chemistry 303"}, {"element_id": "18", "label": "Course", "name": "Mathematics 404"}, {"element_id": "19", "label": "Department", "department": "Science"}, {"element_id": "20", "label": "Department", "department": "Arts"}, {"element_id": "21", "label": "Department", "department": "Engineering"}], "edges": [{"label": "WORKS_AT", "element_id": "10", "start": "12", "end": "19"}, {"label": "WORKS_AT", "element_id": "11", "start": "13", "end": "20"}, {"label": "WORKS_AT", "element_id": "12", "start": "14", "end": "21"}, {"label": "RESPONSIBLE_FOR", "element_id": "13", "start": "11", "end": "15"}, {"label": "RESPONSIBLE_FOR", "element_id": "14", "start": "12", "end": "15"}, {"label": "RESPONSIBLE_FOR", "element_id": "15", "start": "13", "end": "15"}, {"label": "RESPONSIBLE_FOR", "element_id": "16", "start": "13", "end": "16"}, {"label": "RESPONSIBLE_FOR", "element_id": "17", "start": "12", "end": "16"}, {"label": "RESPONSIBLE_FOR", "element_id": "18", "start": "13", "end": "17"}, {"label": "RESPONSIBLE_FOR", "element_id": "19", "start": "11", "end": "16"}, {"label": "RESPONSIBLE_FOR", "element_id": "20", "start": "14", "end": "18"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n18"], "property": "full"}], "table": [[1, 3, 5, 7, 9, 11, 13, 15], [2, 4, 6, 8, 10, 12, 14, 16]]}>>))


(check-synth)
                