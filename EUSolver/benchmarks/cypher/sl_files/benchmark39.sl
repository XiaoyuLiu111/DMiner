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
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Maria Smith"))

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


(constraint (= (f <<{"nodes": [{"element_id": "22", "label": "Department", "department": "Math"}, {"element_id": "23", "label": "Department", "department": "Science"}, {"element_id": "24", "label": "Department", "department": "Science"}, {"element_id": "25", "label": "Department", "department": "Science"}, {"element_id": "26", "label": "Department", "department": "Socials"}, {"element_id": "27", "label": "Department", "department": "Economics"}, {"element_id": "28", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "29", "label": "Tutor", "name": "Mary"}, {"element_id": "30", "label": "Tutor", "name": "Joe Smith"}, {"element_id": "31", "label": "Course", "name": "Calculus 1"}, {"element_id": "32", "label": "Course", "name": "Linear Algebra"}, {"element_id": "33", "label": "Course", "name": "Topology"}, {"element_id": "34", "label": "Course", "name": "Graph Theory"}, {"element_id": "35", "label": "Course", "name": "Chemistry 100"}, {"element_id": "36", "label": "Course", "name": "Biology 100"}, {"element_id": "37", "label": "Course", "name": "Physics 100"}, {"element_id": "40", "label": "Course", "name": "Space 100"}, {"element_id": "41", "label": "Course", "name": "Canadian Confederation"}, {"element_id": "42", "label": "Course", "name": "History 100"}, {"element_id": "43", "label": "Course", "name": "Macroeconomics"}, {"element_id": "44", "label": "Course", "name": "Microeconomics"}, {"element_id": "45", "label": "Course", "name": "Game Theory"}, {"element_id": "46", "label": "Course", "name": "Economic Policy"}, {"element_id": "47", "label": "Course", "name": "Computational Economics"}], "edges": [{"label": "RESPONSIBLE_FOR", "element_id": "4", "start": "28", "end": "36"}, {"label": "WORKS_AT", "element_id": "5", "start": "28", "end": "23"}, {"label": "WORKS_AT", "element_id": "6", "start": "30", "end": "24"}, {"label": "RESPONSIBLE_FOR", "element_id": "7", "start": "30", "end": "33"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n28"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n36"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e4"], "property": "full"}], "table": [[1], [3], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "1", "label": "Course", "name": "Biology 101"}, {"element_id": "2", "label": "Department", "department": "Science"}], "edges": [{"label": "WORKS_AT", "element_id": "0", "start": "0", "end": "2"}, {"label": "RESPONSIBLE_FOR", "element_id": "1", "start": "0", "end": "1"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e1"], "property": "full"}], "table": [[1], [3], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "25", "label": "Department", "department": "Math"}, {"element_id": "26", "label": "Department", "department": "Science"}, {"element_id": "27", "label": "Department", "department": "Science"}, {"element_id": "28", "label": "Department", "department": "Science"}, {"element_id": "29", "label": "Department", "department": "Socials"}, {"element_id": "30", "label": "Department", "department": "Economics"}, {"element_id": "31", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "32", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "33", "label": "Tutor", "name": "Mary"}, {"element_id": "34", "label": "Tutor", "name": "Joe Smith"}, {"element_id": "35", "label": "Course", "name": "Calculus 1"}, {"element_id": "36", "label": "Course", "name": "Linear Algebra"}, {"element_id": "37", "label": "Course", "name": "Topology"}, {"element_id": "38", "label": "Course", "name": "Graph Theory"}, {"element_id": "39", "label": "Course", "name": "Chemistry 100"}, {"element_id": "40", "label": "Course", "name": "Biology 100"}, {"element_id": "41", "label": "Course", "name": "Physics 100"}, {"element_id": "42", "label": "Course", "name": "Space 100"}, {"element_id": "43", "label": "Course", "name": "Canadian Confederation"}, {"element_id": "44", "label": "Course", "name": "History 100"}, {"element_id": "45", "label": "Course", "name": "Macroeconomics"}, {"element_id": "46", "label": "Course", "name": "Microeconomics"}, {"element_id": "47", "label": "Course", "name": "Game Theory"}, {"element_id": "48", "label": "Course", "name": "Economic Policy"}, {"element_id": "49", "label": "Course", "name": "Computational Economics"}], "edges": [{"label": "RESPONSIBLE_FOR", "element_id": "3", "start": "31", "end": "36"}, {"label": "WORKS_AT", "element_id": "4", "start": "31", "end": "25"}, {"label": "WORKS_AT", "element_id": "5", "start": "31", "end": "26"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n31"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n36"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n31"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n36"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e3"], "property": "full"}], "table": [[1, 3], [5, 6], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "26", "label": "Department", "department": "Math"}, {"element_id": "27", "label": "Department", "department": "Science"}, {"element_id": "28", "label": "Department", "department": "Science"}, {"element_id": "29", "label": "Department", "department": "Science"}, {"element_id": "30", "label": "Department", "deparment": "Socials"}, {"element_id": "31", "label": "Department", "department": "Economics"}, {"element_id": "32", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "33", "label": "Tutor", "name": "Maria Smith"}, {"element_id": "34", "label": "Tutor", "name": "Mary"}, {"element_id": "35", "label": "Course", "name": "Physics 100"}, {"element_id": "36", "label": "Course", "name": "Macroeconomics"}, {"element_id": "37", "label": "Tutor", "name": "Maria Smith"}], "edges": [{"label": "RESPONSIBLE_FOR", "element_id": "5", "start": "37", "end": "36"}, {"label": "WORKS_AT", "element_id": "6", "start": "37", "end": "31"}, {"label": "WORKS_AT", "element_id": "7", "start": "37", "end": "27"}, {"label": "WORKS_AT", "element_id": "8", "start": "34", "end": "29"}, {"label": "RESPONSIBLE_FOR", "element_id": "9", "start": "34", "end": "35"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n37"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n36"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n37"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n36"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e5"], "property": "full"}], "table": [[1, 3], [5, 6], [2, 4]]}>>))


(check-synth)
                