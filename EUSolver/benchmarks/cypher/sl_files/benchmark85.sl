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
(NodeLabels String ("Token"))
(NodeProperty String ("text"))
                    
; Edge Information
(EdgeLabels String ("BEFORE"))
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


(constraint (= (f <<{"nodes": [{"element_id": "10", "label": "Token", "text": "AND"}, {"element_id": "11", "label": "Token", "text": ""}, {"element_id": "12", "label": "Token", "text": "God"}, {"element_id": "13", "label": "Token", "text": "The"}, {"element_id": "14", "label": "Token", "text": "Earth"}, {"element_id": "15", "label": "Token", "text": "To"}, {"element_id": "16", "label": "Token", "text": "Called"}, {"element_id": "17", "label": "Token", "text": "Made"}, {"element_id": "18", "label": "Token", "text": "Let"}, {"element_id": "19", "label": "Token", "text": "Firmament"}], "edges": [{"label": "BEFORE", "element_id": "6", "start": "11", "end": "10"}, {"label": "BEFORE", "element_id": "7", "start": "10", "end": "13"}, {"label": "BEFORE", "element_id": "8", "start": "13", "end": "14"}, {"label": "BEFORE", "element_id": "9", "start": "10", "end": "17"}, {"label": "BEFORE", "element_id": "10", "start": "10", "end": "12"}, {"label": "BEFORE", "element_id": "11", "start": "12", "end": "16"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n12"], "property": "full"}], "table": [[1, 3, 5, 7, 9, 11], [2, 4, 6, 8, 10, 12]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "5", "label": "Token", "text": "AND"}, {"element_id": "6", "label": "Token", "text": ""}, {"element_id": "7", "label": "Token", "text": "God"}, {"element_id": "8", "label": "Token", "text": "The"}, {"element_id": "9", "label": "Token", "text": "Earth"}], "edges": [{"label": "BEFORE", "element_id": "3", "start": "6", "end": "5"}, {"label": "BEFORE", "element_id": "4", "start": "5", "end": "8"}, {"label": "BEFORE", "element_id": "5", "start": "5", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}], "table": [[1, 3], [2, 4]]}>>))


(check-synth)
                