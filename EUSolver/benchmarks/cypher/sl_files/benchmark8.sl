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
(NodeLabels String ("Child" "Parent"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("SISTER" "MARRIED_TO" "BROTHER" "HAS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Daughter" "Bob"))

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


(constraint (= (f <<{"nodes": [{"element_id": "16", "label": "Parent", "name": "Bob"}, {"element_id": "17", "label": "Parent", "name": "Bob"}, {"element_id": "18", "label": "Parent", "name": "Bob"}, {"element_id": "19", "label": "Parent", "name": "Bob"}, {"element_id": "20", "label": "Parent", "name": "Kate"}, {"element_id": "21", "label": "Parent", "name": "Jason"}, {"element_id": "22", "label": "Parent", "name": "Katherine"}, {"element_id": "23", "label": "Parent", "name": "Mike"}, {"element_id": "24", "label": "Parent", "name": "Jessica"}, {"element_id": "25", "label": "Parent", "name": "Vicky"}, {"element_id": "26", "label": "Parent", "name": "Dylon"}, {"element_id": "27", "label": "Parent", "name": "Lee"}, {"element_id": "28", "label": "Parent", "name": "Diana"}, {"element_id": "29", "label": "Child", "name": "Son"}, {"element_id": "30", "label": "Child", "name": "Daughter"}, {"element_id": "31", "label": "Child", "name": "Son2"}, {"element_id": "32", "label": "Child", "name": "Daughter"}, {"element_id": "33", "label": "Child", "name": "Daughter"}], "edges": [{"label": "HAS", "element_id": "15", "start": "18", "end": "29"}, {"label": "HAS", "element_id": "16", "start": "16", "end": "29"}, {"label": "HAS", "element_id": "17", "start": "19", "end": "31"}, {"label": "HAS", "element_id": "18", "start": "16", "end": "31"}, {"label": "HAS", "element_id": "19", "start": "25", "end": "32"}, {"label": "HAS", "element_id": "20", "start": "26", "end": "32"}, {"label": "HAS", "element_id": "21", "start": "28", "end": "33"}, {"label": "HAS", "element_id": "22", "start": "27", "end": "33"}, {"label": "MARRIED_TO", "element_id": "23", "start": "20", "end": "24"}, {"label": "MARRIED_TO", "element_id": "24", "start": "30", "end": "29"}, {"label": "BROTHER", "element_id": "25", "start": "29", "end": "31"}, {"label": "MARRIED_TO", "element_id": "26", "start": "31", "end": "32"}, {"label": "SISTER", "element_id": "27", "start": "32", "end": "33"}, {"label": "HAS", "element_id": "28", "start": "16", "end": "30"}, {"label": "HAS", "element_id": "29", "start": "17", "end": "30"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}], "table": [[1, 3], [2, 4]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Parent", "name": "Bob"}, {"element_id": "5", "label": "Parent", "name": "Bob"}, {"element_id": "6", "label": "Child", "name": "Daughter"}, {"element_id": "7", "label": "Parent", "name": "Jessica"}], "edges": [{"label": "HAS", "element_id": "3", "start": "4", "end": "6"}, {"label": "HAS", "element_id": "4", "start": "5", "end": "6"}, {"label": "MARRIED_TO", "element_id": "5", "start": "4", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}], "table": [[1, 3], [2, 4]]}>>))


(check-synth)
                