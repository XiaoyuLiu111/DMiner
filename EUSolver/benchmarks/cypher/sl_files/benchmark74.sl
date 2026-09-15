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
(NodeLabels String ("Person" "Movie"))
(NodeProperty String ("title" "name"))
                    
; Edge Information
(EdgeLabels String ("DIRECTED" "ACTED_IN"))
(EdgeProperty String ("role"))

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Wall Sreet"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Charlie Sheen"}, {"element_id": "1", "label": "Person", "name": "Martin Sheen"}, {"element_id": "2", "label": "Person", "name": "Michael Douglas"}, {"element_id": "3", "label": "Person", "name": "Oliver Stone"}, {"element_id": "4", "label": "Person", "name": "Rob Reiner"}, {"element_id": "5", "label": "Movie", "title": "Wall Street"}, {"element_id": "6", "label": "Movie", "title": "The American President"}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "0", "end": "5", "role": "Bud Fox"}, {"label": "ACTED_IN", "element_id": "1", "start": "1", "end": "5", "role": "Carl Fox"}, {"label": "ACTED_IN", "element_id": "2", "start": "2", "end": "5", "role": "Gordon Gekko"}, {"label": "DIRECTED", "element_id": "3", "start": "3", "end": "5"}, {"label": "ACTED_IN", "element_id": "4", "start": "1", "end": "6", "role": "A.J. MacInerney"}, {"label": "ACTED_IN", "element_id": "5", "start": "2", "end": "6", "role": "President Andrew Shepherd"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e3"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e3"], "property": "full"}], "table": [[1, 4, 7], [10, 12, 14], [2, 5, 8], [11, 13, 15], [3, 6, 9]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "4", "label": "Person", "name": "Charlie Sheen"}, {"element_id": "5", "label": "Person", "name": "Martin Sheen"}, {"element_id": "6", "label": "Person", "name": "Oliver"}, {"element_id": "7", "label": "Movie", "title": "Wall Street"}], "edges": [{"label": "ACTED_IN", "element_id": "2", "start": "4", "end": "7", "role": "Bud Fox"}, {"label": "DIRECTED", "element_id": "3", "start": "6", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n4"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n6"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e3"], "property": "full"}], "table": [[1], [4], [2], [5], [3]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Person", "name": "Charlie Sheen"}, {"element_id": "1", "label": "Person", "name": "Martin Sheen"}, {"element_id": "2", "label": "Person", "name": "Oliver Stone"}, {"element_id": "3", "label": "Person", "name": "Orlando Jones"}, {"element_id": "4", "label": "Person", "name": "Howard Deautch"}, {"element_id": "5", "label": "Movie", "title": "Wall Street"}, {"element_id": "6", "label": "Movie", "title": "The Replacements"}], "edges": [{"label": "ACTED_IN", "element_id": "0", "start": "1", "end": "5", "role": "Carl Fox"}, {"label": "DIRECTED", "element_id": "1", "start": "2", "end": "5"}, {"label": "ACTED_IN", "element_id": "2", "start": "3", "end": "6", "role": "Bud Fox"}, {"label": "DIRECTED", "element_id": "3", "start": "4", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["e1"], "property": "full"}], "table": [[1], [4], [2], [5], [3]]}>>))


(check-synth)
                