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
(NodeLabels String ("Dog" "Toy" "Person"))
(NodeProperty String ("age" "name" "email"))
                    
; Edge Information
(EdgeLabels String ())
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n0"))
(EdgeVars String ())
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Peter" "30" "Timothy"))

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
                    NodeVars
                    ))

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


(constraint (= (f <<{"nodes": [{"element_id": "7", "label": "Dog", "name": "Andy"}, {"element_id": "8", "label": "Person", "name": "Andy", "email": "andy_n@example.com", "age": 36}, {"element_id": "9", "label": "Person", "name": "Peter", "email": "peter_n@example.com", "age": 35}, {"element_id": "10", "label": "Person", "name": "Timothy", "email": "timothy_n@example.com", "age": 25}, {"element_id": "11", "label": "Dog", "name": "Fido"}, {"element_id": "12", "label": "Dog", "name": "Ozzy"}, {"element_id": "13", "label": "Toy", "name": "Banana"}], "edges": [{"label": "HAS_DOG", "element_id": "3", "start": "8", "end": "7", "since": 2016}, {"label": "KNOWS", "element_id": "4", "start": "8", "end": "10", "since": 2012}, {"label": "HAS_DOG", "element_id": "5", "start": "10", "end": "12", "since": 2018}, {"label": "HAS_DOG", "element_id": "8", "start": "10", "end": "11", "since": 2010}, {"label": "HAS_TOY", "element_id": "9", "start": "11", "end": "13"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "age"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Person", "name": "Peter", "age": 30, "email": "peter_1@example.com"}, {"element_id": "7", "label": "Person", "name": "Peter", "age": 27, "email": "peter_2@example.com"}, {"element_id": "8", "label": "Person", "name": "Peter", "age": 15, "email": "peter_3@example.com"}, {"element_id": "9", "label": "Person", "name": "Amy", "age": 25, "email": "amy@example.com"}, {"element_id": "10", "label": "Person", "name": "Amy", "age": 30, "email": "amy@example.com"}, {"element_id": "11", "label": "Person", "name": "Timothy", "age": 39, "email": "timothy@example.com"}, {"element_id": "13", "label": "Person", "name": "Peter", "age": 32, "email": "peter_4@example.com"}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n9"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n13"], "property": "age"}], "table": [[1, 3, 5], [2, 4, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Timothy", "age": 30, "email": "timothy_1@example.com"}, {"element_id": "1", "label": "Person", "name": "Timothy", "age": 37, "email": "timothy_2@example.com"}, {"element_id": "2", "label": "Person", "name": "Timothy", "age": 28, "email": "timothy_3@example.com"}, {"element_id": "3", "label": "Person", "name": "Timothy", "age": 12, "email": "timothy_4@example.com"}, {"element_id": "4", "label": "Person", "name": "Tracy", "age": 30, "email": "tracy@example.com"}, {"element_id": "11", "label": "Person", "name": "Peter", "age": 31, "email": "peter_3@example.com"}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "age"}], "table": [[1, 3, 5, 7], [2, 4, 6, 8]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Timothy", "age": 30, "email": "timothy_1@example.com"}, {"element_id": "1", "label": "Person", "name": "Timothy", "age": 47, "email": "timothy_2@example.com"}, {"element_id": "2", "label": "Person", "name": "Timothy", "age": 26, "email": "timothy_3@example.com"}, {"element_id": "3", "label": "Person", "name": "Timothy", "age": 17, "email": "timothy_4@example.com"}, {"element_id": "4", "label": "Person", "name": "Tracy", "age": 17, "email": "tracy@example.com"}, {"element_id": "11", "label": "Person", "name": "Peter", "age": 31, "email": "peter_3@example.com"}], "edges": []}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n11"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "age"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "name"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "age"}], "table": [[1, 3, 5, 7], [2, 4, 6, 8]]}>>))


(check-synth)
                