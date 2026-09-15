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
(NodeProperty String ())
                    
; Edge Information
(EdgeLabels String ("r"))
(EdgeProperty String ("ref_id" "cid"))

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("01" "02" "0001"))

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


(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Node"}, {"element_id": "1", "label": "Node"}, {"element_id": "2", "label": "Node"}, {"element_id": "3", "label": "Node"}, {"element_id": "8", "label": "Node"}, {"element_id": "10", "label": "Node"}, {"element_id": "11", "label": "Node"}, {"element_id": "12", "label": "Node"}], "edges": [{"label": "r", "element_id": "2", "start": "0", "end": "1", "ref_id": "0003", "cid": "01"}, {"label": "r", "element_id": "3", "start": "1", "end": "3", "ref_id": "0001", "cid": "02"}, {"label": "r", "element_id": "4", "start": "1", "end": "2", "ref_id": "0001", "cid": "03"}, {"label": "r", "element_id": "5", "start": "1", "end": "8", "ref_id": "0001", "cid": "04"}, {"label": "r", "element_id": "6", "start": "10", "end": "11", "ref_id": "0007", "cid": "03"}, {"label": "r", "element_id": "7", "start": "11", "end": "12", "ref_id": "0001", "cid": "02"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n3"], "property": "full"}], "table": [[1], [2], [3]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Node"}, {"element_id": "1", "label": "Node"}, {"element_id": "2", "label": "Node"}, {"element_id": "3", "label": "Node"}, {"element_id": "4", "label": "Node"}, {"element_id": "10", "label": "Node"}, {"element_id": "11", "label": "Node"}, {"element_id": "12", "label": "Node"}, {"element_id": "13", "label": "Node"}, {"element_id": "14", "label": "Node"}, {"element_id": "15", "label": "Node"}], "edges": [{"label": "r", "element_id": "0", "start": "0", "end": "1", "ref_id": "0007", "cid": "01"}, {"label": "r", "element_id": "1", "start": "1", "end": "2", "ref_id": "0001", "cid": "02"}, {"label": "r", "element_id": "2", "start": "4", "end": "10", "ref_id": "0007", "cid": "01"}, {"label": "r", "element_id": "3", "start": "10", "end": "11", "ref_id": "0002", "cid": "02"}, {"label": "r", "element_id": "5", "start": "11", "end": "12", "ref_id": "0003", "cid": "02"}, {"label": "r", "element_id": "6", "start": "13", "end": "14", "ref_id": "0001", "cid": "04"}, {"label": "r", "element_id": "7", "start": "14", "end": "15", "ref_id": "0001", "cid": "02"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n1"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "full"}], "table": [[1], [2], [3]]}>>))


(check-synth)
                