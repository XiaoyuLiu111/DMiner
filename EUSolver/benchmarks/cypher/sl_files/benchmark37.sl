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
(EdgeLabels String ("RESPONSIBLE_FOR" "WORKS_AT"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Department", "department": "Math"}, {"element_id": "1", "label": "Department", "department": "Science"}, {"element_id": "2", "label": "Department", "department": "Socials"}, {"element_id": "3", "label": "Department", "department": "Economics"}, {"element_id": "4", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "5", "label": "Tutor", "name": "Mary"}, {"element_id": "6", "label": "Course", "name": "Calculus 1"}, {"element_id": "7", "label": "Course", "name": "Linear Algebra"}, {"element_id": "8", "label": "Course", "name": "Graph Theory"}, {"element_id": "9", "label": "Course", "name": "Chemistry 100"}, {"element_id": "10", "label": "Course", "name": "Physics 100"}], "edges": [{"label": "RESPONSIBLE_FOR", "element_id": "0", "start": "4", "end": "7"}, {"label": "WORKS_AT", "element_id": "1", "start": "4", "end": "1"}, {"label": "WORKS_AT", "element_id": "2", "start": "4", "end": "0"}, {"label": "RESPONSIBLE_FOR", "element_id": "3", "start": "5", "end": "10"}, {"label": "WORKS_AT", "element_id": "4", "start": "5", "end": "2"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "1", "label": "Tutor", "name": "Max"}, {"element_id": "2", "label": "Course", "name": "Biology 101"}, {"element_id": "3", "label": "Department", "department": "Science"}], "edges": [{"label": "WORKS_AT", "element_id": "0", "start": "0", "end": "3"}, {"label": "WORKS_AT", "element_id": "1", "start": "1", "end": "3"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Department", "department": "Science"}, {"element_id": "1", "label": "Department", "department": "Socials"}, {"element_id": "2", "label": "Course", "name": "Topology"}, {"element_id": "3", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "4", "label": "Course", "name": "Biology 100"}, {"element_id": "5", "label": "Tutor", "name": "Joe Smith"}], "edges": [{"label": "RESPONSIBLE_FOR", "element_id": "0", "start": "3", "end": "4"}, {"label": "WORKS_AT", "element_id": "1", "start": "3", "end": "0"}, {"label": "WORKS_AT", "element_id": "2", "start": "5", "end": "0"}, {"label": "RESPONSIBLE_FOR", "element_id": "3", "start": "5", "end": "2"}, {"label": "WORKS_AT", "element_id": "4", "start": "5", "end": "1"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Department", "department": "Science"}, {"element_id": "5", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "6", "label": "Course", "name": "Macroeconomics"}, {"element_id": "7", "label": "Tutor", "name": "Mary"}], "edges": [{"label": "RESPONSIBLE_FOR", "element_id": "2", "start": "5", "end": "6"}, {"label": "WORKS_AT", "element_id": "3", "start": "7", "end": "4"}, {"label": "WORKS_AT", "element_id": "4", "start": "5", "end": "4"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}], "table": [[1]]}>>))


(check-synth)
                