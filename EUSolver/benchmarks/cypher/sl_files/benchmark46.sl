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
(NodeLabels String ("Place" "Category"))
(NodeProperty String ("name"))
                    
; Edge Information
(EdgeLabels String ("IS_A"))
(EdgeProperty String ())

; Variable References (determines max path length)
(NodeVars String ("n1" "n0"))
(EdgeVars String ("e0"))
(Vars String (NodeVars EdgeVars))

; Constants
(Values String ("Food" "Bar"))

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


(constraint (= (f <<{"nodes": [{"element_id": "13", "label": "Place", "name": "Central Park"}, {"element_id": "14", "label": "Category", "name": "Park"}, {"element_id": "15", "label": "Place", "name": "Stanley Park"}, {"element_id": "16", "label": "Place", "name": "Burnaby Mountain"}, {"element_id": "17", "label": "Place", "name": "Joe's Diner"}, {"element_id": "18", "label": "Category", "name": "Food"}, {"element_id": "19", "label": "Place", "name": "The Mackenzie Room"}, {"element_id": "20", "label": "Place", "name": "The Keefer"}, {"element_id": "21", "label": "Place", "name": "Say Mercy"}, {"element_id": "22", "label": "Place", "name": "Cactus Club"}, {"element_id": "23", "label": "Place", "name": "Joe's Diner"}, {"element_id": "24", "label": "Category", "name": "Bar"}, {"element_id": "25", "label": "Place", "name": "Bartholomews"}], "edges": [{"label": "IS_A", "element_id": "10", "start": "13", "end": "14"}, {"label": "IS_A", "element_id": "11", "start": "15", "end": "14"}, {"label": "IS_A", "element_id": "12", "start": "16", "end": "14"}, {"label": "IS_A", "element_id": "13", "start": "17", "end": "18"}, {"label": "IS_A", "element_id": "14", "start": "19", "end": "14"}, {"label": "IS_A", "element_id": "15", "start": "20", "end": "18"}, {"label": "IS_A", "element_id": "16", "start": "21", "end": "18"}, {"label": "IS_A", "element_id": "17", "start": "22", "end": "18"}, {"label": "IS_A", "element_id": "18", "start": "23", "end": "24"}, {"label": "IS_A", "element_id": "19", "start": "25", "end": "24"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n22"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n21"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n20"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n17"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n25"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n23"], "property": "full"}], "table": [[1, 2, 3, 4, 5, 6]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "15", "label": "Category", "name": "Bar"}, {"element_id": "16", "label": "Category", "name": "Food"}, {"element_id": "17", "label": "Category", "name": "Cafe"}, {"element_id": "18", "label": "Category", "name": "Lounge"}, {"element_id": "19", "label": "Category", "name": "Club"}, {"element_id": "20", "label": "Place", "name": "Cheers"}, {"element_id": "21", "label": "Place", "name": "The Bistro"}, {"element_id": "22", "label": "Place", "name": "Central Perk"}, {"element_id": "23", "label": "Place", "name": "Blue Note"}, {"element_id": "24", "label": "Place", "name": "Velvet Lounge"}, {"element_id": "25", "label": "Place", "name": "The Dive"}, {"element_id": "26", "label": "Place", "name": "Club Havana"}, {"element_id": "27", "label": "Place", "name": "The Corner"}, {"element_id": "28", "label": "Place", "name": "The Spot"}, {"element_id": "29", "label": "Place", "name": "Jazz Corner"}], "edges": [{"label": "IS_A", "element_id": "7", "start": "20", "end": "15"}, {"label": "IS_A", "element_id": "8", "start": "21", "end": "16"}, {"label": "IS_A", "element_id": "9", "start": "22", "end": "17"}, {"label": "IS_A", "element_id": "10", "start": "23", "end": "18"}, {"label": "IS_A", "element_id": "11", "start": "24", "end": "19"}, {"label": "IS_A", "element_id": "12", "start": "26", "end": "19"}, {"label": "IS_A", "element_id": "13", "start": "27", "end": "16"}, {"label": "IS_A", "element_id": "14", "start": "28", "end": "17"}, {"label": "IS_A", "element_id": "15", "start": "29", "end": "18"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n20"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n27"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n21"], "property": "full"}], "table": [[1, 2, 3]]}>>))

(constraint (= (f <<{"nodes": [{"element_id": "0", "label": "Category", "name": "Food"}, {"element_id": "1", "label": "Category", "name": "Bar"}, {"element_id": "2", "label": "Category", "name": "Park"}, {"element_id": "3", "label": "Place", "name": "Central Park"}, {"element_id": "4", "label": "Category", "name": "Park"}, {"element_id": "5", "label": "Place", "name": "Joe's Diner"}, {"element_id": "6", "label": "Category", "name": "Food"}, {"element_id": "7", "label": "Place", "name": "Joe's Diner"}, {"element_id": "8", "label": "Category", "name": "Bar"}], "edges": [{"label": "IS_A", "element_id": "0", "start": "3", "end": "4"}, {"label": "IS_A", "element_id": "1", "start": "5", "end": "6"}, {"label": "IS_A", "element_id": "2", "start": "7", "end": "8"}]}>>) 
                <<{"outputGraph": [{"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n5"], "property": "full"}, {"operator": "", "lhs": {}, "rhs": {}, "inputItems": ["n7"], "property": "full"}], "table": [[1, 2]]}>>))


(check-synth)
                