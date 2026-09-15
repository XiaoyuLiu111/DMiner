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
(NodeLabels String ("Person"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("MY_RELATION"))
(EdgeProperty String ("minimum" "maximum"))

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("21"))

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


(constraint (= (f <<{"nodes": [{"element_id": "1", "label": "Person", "name": "P01"}, {"element_id": "2", "label": "Person", "name": "P01"}, {"element_id": "3", "label": "Person", "name": "P01"}, {"element_id": "7", "label": "Person", "name": "P01"}], "edges": [{"label": "MY_RELATION", "element_id": "2", "start": "1", "end": "2", "maximum": 23, "minimum": 20}, {"label": "MY_RELATION", "element_id": "3", "start": "3", "end": "7", "maximum": 18, "minimum": 15}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e2"], "property": "full"}], "table": [[1], [3], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "P01"}, {"element_id": "1", "label": "Person", "name": "P01"}, {"element_id": "2", "label": "Person", "name": "P01"}, {"element_id": "3", "label": "Person", "name": "P01"}, {"element_id": "4", "label": "Person", "name": "P01"}, {"element_id": "10", "label": "Person", "name": "P01"}], "edges": [{"label": "MY_RELATION", "element_id": "0", "start": "0", "end": "1", "maximum": 25, "minimum": 21}, {"label": "MY_RELATION", "element_id": "1", "start": "1", "end": "2", "maximum": 22, "minimum": 20}, {"label": "MY_RELATION", "element_id": "2", "start": "2", "end": "3", "maximum": 25, "minimum": 22}, {"label": "MY_RELATION", "element_id": "3", "start": "3", "end": "4", "maximum": 20, "minimum": 19}, {"label": "MY_RELATION", "element_id": "4", "start": "4", "end": "10", "maximum": 21, "minimum": 3}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e4"], "property": "full"}], "table": [[1, 3, 5], [7, 8, 9], [2, 4, 6]]}>>))


(check-synth)
                