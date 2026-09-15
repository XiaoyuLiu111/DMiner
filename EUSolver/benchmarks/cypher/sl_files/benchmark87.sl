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
(NodeProperty String ("age" "name"))
                    
; Edge Information
(EdgeLabels String ())
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ())
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("40"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Andy", "age": 36}, {"element_id": "1", "label": "Person", "name": "Timothy", "age": 38}, {"element_id": "2", "label": "Person", "name": "Peter", "age": 35}, {"element_id": "6", "label": "Person", "name": "Lisa", "age": 48}, {"element_id": "7", "label": "Person", "name": "John", "age": 40}, {"element_id": "8", "label": "Person", "name": "Susan", "age": 32}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1", "since": 2012}, {"label": "KNOWS", "element_id": "1", "start": "0", "end": "2", "since": 1999}, {"label": "KNOWS", "element_id": "4", "start": "2", "end": "6", "since": 2005}, {"label": "KNOWS", "element_id": "5", "start": "6", "end": "7", "since": 2010}, {"label": "KNOWS", "element_id": "6", "start": "7", "end": "8", "since": 2021}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "age"}], "table": [[1], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "15", "label": "Person", "name": "Amy", "age": 41}, {"element_id": "16", "label": "Person", "name": "Lucy", "age": 45}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n15"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n16"], "property": "age"}], "table": [[1, 2], [3, 4]]}>>))


(check-synth)
                