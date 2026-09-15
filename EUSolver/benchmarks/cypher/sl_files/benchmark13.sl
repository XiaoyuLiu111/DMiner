(set-logic CYPHER)

; This is the framework for the grammar that can then just be "filled in" for each benchmark

(synth-fun f ((input Graph)) Graph

((Start Graph (Return))
(Input Graph (input))
(Return Graph ((return Clause ReturnList)))
(Clause Graph ((match Input PathPattern) (matchr Clause PathPattern)))
                    
; Patterns
(NodePattern String ((createNodePattern NodeVars NodeLabels)))
(EdgePattern String ((createEdgePattern EdgeVars EdgeLabels Direction)))
(Direction String ("->" "<-"))
(PathPattern String (NodePattern
                    (createPathPattern NodePattern EdgePattern PathPattern)))
                    
; Node Information 
(NodeLabels String ("Person"))
(NodeProperty String ("age" "job"))
                    
; Edge Information
(EdgeLabels String ())
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ())
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ())

; Combined Node/Edge Properties
(Properties String ((getProperty NodeVars NodeProperty)
                    (getProperty EdgeVars EdgeProperty)))

; Aggregators
(Aggregators String ((COUNT AggregatorsSub)))

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


(constraint (= (f <<{"nodes": [{"element_id": "7", "label": "Person", "job": "SW engineer", "age": 20}, {"element_id": "8", "label": "Person", "job": "HW engineer", "age": 21}, {"element_id": "9", "label": "Person", "job": "SW engineer", "age": 22}, {"element_id": "10", "label": "Person", "job": "boss", "age": 40}, {"element_id": "11", "label": "Person", "job": "architect", "age": 40}, {"element_id": "12", "label": "Person", "job": "boss", "age": 99}, {"element_id": "13", "label": "Person", "job": "boss", "age": 30}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7", "n9"], "property": "job"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "job"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10", "n12", "n13"], "property": "job"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "job"}, {"inputItems": ["n7", "n9"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n8"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n10", "n12", "n13"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n11"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1, 2, 3, 4], [5, 6, 7, 8]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "job": "Engineer", "age": 30}, {"element_id": "1", "label": "Person", "job": "Doctor", "age": 45}, {"element_id": "2", "label": "Person", "job": "Engineer", "age": 28}, {"element_id": "3", "label": "Person", "job": "Teacher", "age": 35}, {"element_id": "4", "label": "Person", "job": "Doctor", "age": 50}, {"element_id": "5", "label": "Person", "job": "Artist", "age": 40}, {"element_id": "6", "label": "Person", "job": "Teacher", "age": 29}, {"element_id": "7", "label": "Person", "job": "Engineer", "age": 42}, {"element_id": "8", "label": "Person", "job": "Artist", "age": 33}, {"element_id": "9", "label": "Person", "job": "Doctor", "age": 38}, {"element_id": "10", "label": "Person", "job": "Engineer", "age": 27}, {"element_id": "11", "label": "Person", "job": "Teacher", "age": 32}, {"element_id": "12", "label": "Person", "job": "Engineer", "age": 55}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0", "n2", "n7", "n10", "n12"], "property": "job"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1", "n4", "n9"], "property": "job"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3", "n6", "n11"], "property": "job"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5", "n8"], "property": "job"}, {"inputItems": ["n0", "n2", "n7", "n10", "n12"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n1", "n4", "n9"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n3", "n6", "n11"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}, {"inputItems": ["n5", "n8"], "property": "job", "operator": "count", "lhs": {}, "rhs": {}}], "table": [[1, 2, 3, 4], [5, 6, 7, 8]]}>>))


(check-synth)
                