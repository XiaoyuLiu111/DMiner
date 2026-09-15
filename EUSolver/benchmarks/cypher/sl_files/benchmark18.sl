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
(NodeLabels String ("Node"))
(NodeProperty String ("worked" "retired"))
                    
; Edge Information
(EdgeLabels String ("RELATED"))
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
                    NodeVars
                    EdgeVars
                    (eadd ReturnAtom ReturnAtom)
                    (esub ReturnAtom ReturnAtom)
                    (emul ReturnAtom ReturnAtom)
                    (ediv ReturnAtom ReturnAtom)))

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


(constraint (= (f <<{"nodes": [{"element_id": "1", "label": "Node", "worked": 70, "retired": 6}, {"element_id": "2", "label": "Node", "worked": 5, "retired": 0}], "edges": []}>>) 
                <<{"outputGraph": [{"inputItems": [], "property": "", "operator": "+", "lhs": {"inputItems": ["n1"], "property": "worked", "operator": "empty", "lhs": {}, "rhs": {}}, "rhs": {"inputItems": ["n1"], "property": "retired", "operator": "empty", "lhs": {}, "rhs": {}}}, {"inputItems": [], "property": "", "operator": "+", "lhs": {"inputItems": ["n2"], "property": "worked", "operator": "empty", "lhs": {}, "rhs": {}}, "rhs": {"inputItems": ["n2"], "property": "retired", "operator": "empty", "lhs": {}, "rhs": {}}}], "table": [[1, 2]]}>>))


(check-synth)
                