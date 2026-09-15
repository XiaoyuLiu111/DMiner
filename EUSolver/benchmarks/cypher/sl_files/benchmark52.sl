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
(NodeLabels String ("Gene" "Sample" "Pathway"))
(NodeProperty String ("pathwayName" "geneName" "value" "sampleID"))
                    
; Edge Information
(EdgeLabels String ("Measures" "Part_Of"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n2" "n1" "n0"))
(EdgeVars String ("e1" "e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Pyrimidine metabolism"))

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

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Sample", "sampleID": "S1"}, {"element_id": "1", "label": "Sample", "sampleID": "S2"}, {"element_id": "2", "label": "Gene", "geneName": "BRCA1", "value": 3}, {"element_id": "3", "label": "Gene", "geneName": "TP53", "value": 21}, {"element_id": "4", "label": "Gene", "geneName": "EGFR", "value": 12}, {"element_id": "5", "label": "Pathway", "pathwayName": "Pyrimidine metabolism"}, {"element_id": "6", "label": "Pathway", "pathwayName": "Cell Cycle Regulation"}], "edges": [{"label": "Measures", "element_id": "0", "start": "0", "end": "2"}, {"label": "Measures", "element_id": "1", "start": "1", "end": "3"}, {"label": "Measures", "element_id": "2", "start": "1", "end": "4"}, {"label": "Part_Of", "element_id": "3", "start": "2", "end": "5"}, {"label": "Part_Of", "element_id": "4", "start": "3", "end": "6"}, {"label": "Part_Of", "element_id": "10", "start": "4", "end": "6"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n0"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n2"], "property": "geneName"}], "table": [[1], [2]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "6", "label": "Pathway", "pathwayName": "Pyrimidine metabolism"}, {"element_id": "7", "label": "Pathway", "pathwayName": "Apoptosis"}, {"element_id": "8", "label": "Sample", "sampleID": "S001"}, {"element_id": "9", "label": "Sample", "sampleID": "S003"}, {"element_id": "10", "label": "Gene", "geneName": "BRCA2", "value": 17}, {"element_id": "11", "label": "Gene", "geneName": "CDK1", "value": 32}], "edges": [{"label": "Measures", "element_id": "4", "start": "8", "end": "10"}, {"label": "Measures", "element_id": "5", "start": "9", "end": "11"}, {"label": "Part_Of", "element_id": "6", "start": "10", "end": "6"}, {"label": "Part_Of", "element_id": "7", "start": "11", "end": "7"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n8"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n10"], "property": "geneName"}], "table": [[1], [2]]}>>))


(check-synth)
                