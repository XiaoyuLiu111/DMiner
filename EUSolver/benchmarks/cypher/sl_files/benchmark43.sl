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
(NodeLabels String ("Tool" "User" "user"))
(NodeProperty String ("weight" "name"))
                    
; Edge Information
(EdgeLabels String ("USES"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Jim" "Jack" "John"))

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((SUM AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "User", "name": "Karen"}, {"element_id": "1", "label": "User", "name": "Jim"}, {"element_id": "2", "label": "User", "name": "Jack"}, {"element_id": "3", "label": "User", "name": "John"}, {"element_id": "4", "label": "User", "name": "Henry"}, {"element_id": "5", "label": "User", "name": "Mike"}, {"element_id": "6", "label": "User", "name": "Jessica"}, {"element_id": "7", "label": "User", "name": "James"}, {"element_id": "8", "label": "User", "name": "Maria"}, {"element_id": "9", "label": "Tool", "name": "Hammer", "weight": 100}, {"element_id": "10", "label": "Tool", "name": "Screw", "weight": 5}, {"element_id": "11", "label": "Tool", "name": "Nail", "weight": 5}, {"element_id": "24", "label": "Tool", "name": "Saw", "weight": 60}, {"element_id": "29", "label": "Tool", "name": "Sander", "weight": 90}, {"element_id": "30", "label": "Tool", "name": "Drill", "weight": 78}, {"element_id": "31", "label": "Tool", "name": "Axe", "weight": 110}], "edges": [{"label": "USES", "element_id": "0", "start": "1", "end": "29"}, {"label": "USES", "element_id": "1", "start": "2", "end": "9"}, {"label": "USES", "element_id": "2", "start": "3", "end": "30"}, {"label": "USES", "element_id": "3", "start": "4", "end": "30"}, {"label": "USES", "element_id": "4", "start": "6", "end": "9"}, {"label": "USES", "element_id": "5", "start": "5", "end": "29"}, {"label": "USES", "element_id": "6", "start": "7", "end": "9"}, {"label": "USES", "element_id": "7", "start": "8", "end": "29"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}, {"inputItems": ["n29"], "property": "weight", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["n9"], "property": "weight", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["n30"], "property": "weight", "operator": "sum", "lhs": {}, "rhs": {}}], "table": [[1, 2, 3], [4, 5, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "13", "label": "Tool", "name": "Hammer", "weight": 51}, {"element_id": "14", "label": "Tool", "name": "Wrench", "weight": 3}, {"element_id": "15", "label": "Tool", "name": "Screwdriver", "weight": 1}, {"element_id": "16", "label": "Tool", "name": "Drill", "weight": 82}, {"element_id": "17", "label": "Tool", "name": "Saw", "weight": 7}, {"element_id": "18", "label": "User", "name": "Chris"}, {"element_id": "19", "label": "User", "name": "Vicky"}, {"element_id": "20", "label": "User", "name": "Bruce"}, {"element_id": "21", "label": "User", "name": "Jake"}, {"element_id": "22", "label": "User", "name": "Jill"}, {"element_id": "23", "label": "User", "name": "Jim"}, {"element_id": "24", "label": "User", "name": "John"}, {"element_id": "25", "label": "User", "name": "Jack"}], "edges": [{"label": "USES", "element_id": "0", "start": "18", "end": "14"}, {"label": "USES", "element_id": "1", "start": "19", "end": "15"}, {"label": "USES", "element_id": "2", "start": "20", "end": "17"}, {"label": "USES", "element_id": "3", "start": "21", "end": "14"}, {"label": "USES", "element_id": "4", "start": "24", "end": "16"}, {"label": "USES", "element_id": "9", "start": "23", "end": "16"}, {"label": "USES", "element_id": "10", "start": "21", "end": "16"}, {"label": "USES", "element_id": "11", "start": "18", "end": "17"}, {"label": "USES", "element_id": "12", "start": "25", "end": "13"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n23"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n24"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n25"], "property": "name"}, {"inputItems": ["n16"], "property": "weight", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["n16"], "property": "weight", "operator": "sum", "lhs": {}, "rhs": {}}, {"inputItems": ["n13"], "property": "weight", "operator": "sum", "lhs": {}, "rhs": {}}], "table": [[1, 2, 3], [4, 5, 6]]}>>))


(check-synth)
                