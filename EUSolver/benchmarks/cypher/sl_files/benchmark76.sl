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
(EdgeLabels String ("KNOWS"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Andy" "35"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Andy", "age": 36}, {"element_id": "1", "label": "Person", "name": "Timothy", "age": 38}, {"element_id": "2", "label": "Person", "name": "Peter", "age": 35}, {"element_id": "6", "label": "Person", "name": "Lisa", "age": 48}, {"element_id": "7", "label": "Person", "name": "John", "age": 40}, {"element_id": "11", "label": "Person", "name": "Susan", "age": 32}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1"}, {"label": "KNOWS", "element_id": "1", "start": "0", "end": "2"}, {"label": "KNOWS", "element_id": "4", "start": "2", "end": "6"}, {"label": "KNOWS", "element_id": "8", "start": "6", "end": "7"}, {"label": "KNOWS", "element_id": "9", "start": "7", "end": "11"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "name"}], "table": [[1]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Andy", "age": 60}, {"element_id": "1", "label": "Person", "name": "Steve", "age": 34}, {"element_id": "2", "label": "Person", "name": "Kerry", "age": 36}, {"element_id": "8", "label": "Person", "name": "Howard", "age": 38}, {"element_id": "9", "label": "Person", "name": "Matt", "age": 29}, {"element_id": "10", "label": "Person", "name": "Jess", "age": 30}], "edges": [{"label": "KNOWS", "element_id": "0", "start": "0", "end": "1"}, {"label": "KNOWS", "element_id": "1", "start": "0", "end": "2"}, {"label": "KNOWS", "element_id": "5", "start": "0", "end": "8"}, {"label": "KNOWS", "element_id": "6", "start": "9", "end": "10"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}], "table": [[1, 2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "3", "label": "Person", "name": "Matthew", "age": 27}, {"element_id": "4", "label": "Person", "name": "Andy", "age": 23}, {"element_id": "5", "label": "Person", "name": "Kate", "age": 42}, {"element_id": "7", "label": "Person", "name": "James", "age": 36}, {"element_id": "8", "label": "Person", "name": "Jake", "age": 35}], "edges": [{"label": "KNOWS", "element_id": "2", "start": "3", "end": "7"}, {"label": "KNOWS", "element_id": "3", "start": "3", "end": "8"}, {"label": "KNOWS", "element_id": "5", "start": "4", "end": "5"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "name"}], "table": [[1]]}>>))


(check-synth)
                