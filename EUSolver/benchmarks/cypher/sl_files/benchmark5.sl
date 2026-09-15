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
(NodeLabels String ("Person" "question" "Event"))
(NodeProperty String ("firstname" "id"))
                    
; Edge Information
(EdgeLabels String ("CREATED_EVENT" "ANSWERED"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("foo" "2"))

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


(constraint (= (f <<{"nodes": [{"element_id": "14", "label": "Person", "firstname": "foo"}, {"element_id": "15", "label": "Event"}, {"element_id": "16", "label": "question", "id": 2}, {"element_id": "17", "label": "Event"}, {"element_id": "18", "label": "question", "id": 12}, {"element_id": "19", "label": "Event"}, {"element_id": "20", "label": "question", "id": 7}, {"element_id": "21", "label": "Event"}, {"element_id": "22", "label": "question", "id": 2}, {"element_id": "23", "label": "question", "id": 0}, {"element_id": "24", "label": "question", "id": 10}, {"element_id": "25", "label": "question", "id": 19}, {"element_id": "26", "label": "question", "id": 13}, {"element_id": "27", "label": "question", "id": 27}], "edges": [{"label": "CREATED_EVENT", "element_id": "13", "start": "14", "end": "15"}, {"label": "ANSWERED", "element_id": "14", "start": "15", "end": "16"}, {"label": "CREATED_EVENT", "element_id": "15", "start": "14", "end": "17"}, {"label": "ANSWERED", "element_id": "16", "start": "17", "end": "18"}, {"label": "CREATED_EVENT", "element_id": "17", "start": "14", "end": "19"}, {"label": "ANSWERED", "element_id": "18", "start": "19", "end": "20"}, {"label": "CREATED_EVENT", "element_id": "19", "start": "14", "end": "21"}, {"label": "ANSWERED", "element_id": "20", "start": "21", "end": "22"}, {"label": "ANSWERED", "element_id": "21", "start": "15", "end": "23"}, {"label": "ANSWERED", "element_id": "22", "start": "15", "end": "24"}, {"label": "ANSWERED", "element_id": "23", "start": "17", "end": "25"}, {"label": "ANSWERED", "element_id": "24", "start": "19", "end": "26"}, {"label": "ANSWERED", "element_id": "25", "start": "19", "end": "27"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n14"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n21"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n22"], "property": "full"}], "table": [[1, 4], [2, 5], [3, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "firstname": "boo"}, {"element_id": "1", "label": "Event"}, {"element_id": "2", "label": "question", "id": 2}, {"element_id": "3", "label": "Person", "firstname": "a"}, {"element_id": "4", "label": "Event"}, {"element_id": "5", "label": "question", "id": 2}, {"element_id": "6", "label": "Person", "firstname": "foo"}, {"element_id": "7", "label": "Event"}, {"element_id": "8", "label": "question", "id": 2}, {"element_id": "9", "label": "question", "id": 2}], "edges": [{"label": "CREATED_EVENT", "element_id": "0", "start": "0", "end": "1"}, {"label": "ANSWERED", "element_id": "1", "start": "1", "end": "2"}, {"label": "CREATED_EVENT", "element_id": "2", "start": "3", "end": "4"}, {"label": "ANSWERED", "element_id": "3", "start": "4", "end": "5"}, {"label": "CREATED_EVENT", "element_id": "4", "start": "6", "end": "7"}, {"label": "ANSWERED", "element_id": "5", "start": "7", "end": "8"}, {"label": "ANSWERED", "element_id": "6", "start": "7", "end": "9"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}], "table": [[1, 4], [2, 5], [3, 6]]}>>))


(check-synth)
                