from semantics import semantics_types, semantics_lia
from semantics.semantics_types import InterpretedFunctionBase
from exprs import exprtypes

class Return(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('return', 2, (exprtypes.StringType(),exprtypes.StringType()), exprtypes.GraphType())
        self.eval_children = lambda a,b: a.ret(b)

class Match(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('match', 1, (exprtypes.GraphType(),), exprtypes.GraphType())
        self.eval_children = lambda a,b: a.match(b)

class MatchR(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('match', 2, (exprtypes.GraphType(), exprtypes.StringType()), exprtypes.GraphType())
        self.eval_children = lambda a,b: a.matchr(b)

class Filter(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('filter', 2, (exprtypes.GraphType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: a.filter(b)

class CreateNodePattern(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('createNodePattern', 1, (exprtypes.StringType(),), exprtypes.StringType())
        self.eval_children = lambda a,b: f'{a},{b}'

class CreateEdgePattern(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('createEdgePattern', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b,c: f'{a},{b},{c}'

class CreatePathPattern(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('createPathPattern', 3, (exprtypes.StringType(), exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b,c: f'{a}:{b}:{c}'
        
class CreateExpressionList(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('createExpressionList', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'{a}:{b}'

class CreateReturnList(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('createReturnList', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'{a}:{b}'
        
class GetProperty(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('getProperty', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'{a}.{b}'
        
class Add(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('+', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'add({a},{b})'
        self.commutative = True
        self.associative = True
        
class Sub(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('-', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())           
        self.eval_children = lambda a,b: f'sub({a},{b})'
        
class Div(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('-', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())           
        self.eval_children = lambda a,b: f'div({a},{b})'

class Mul(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('-', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())           
        self.eval_children = lambda a,b: f'mul({a},{b})'
        
class Equal(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('=', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'equal({a},{b})'

class Ne(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('<>', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'ne({a},{b})'

class Lt(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('<', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'lt({a},{b})'

class Lte(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('<=', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'lte({a},{b})'

class And(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('and', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'and({a},{b})'
        self.commutative = True
        self.associative = True

class Or(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('or', 2, (exprtypes.StringType(), exprtypes.StringType()), exprtypes.StringType())
        self.eval_children = lambda a,b: f'or({a},{b})'
        self.commutative = True
        self.associative = True

class Count(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('COUNT', 1, (exprtypes.StringType(),), exprtypes.StringType())
        self.eval_children = lambda a: f'COUNT({a})'

class Sum(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('SUM', 1, (exprtypes.StringType(),), exprtypes.StringType())
        self.eval_children = lambda a: f'SUM({a})'

class Max(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('MAX', 1, (exprtypes.StringType(),), exprtypes.StringType())
        self.eval_children = lambda a: f'MAX({a})'

class Min(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('MIN', 1, (exprtypes.StringType(),), exprtypes.StringType())
        self.eval_children = lambda a: f'MIN({a})'

class Avg(InterpretedFunctionBase):
    def __init__(self):
        super().__init__('AVG', 1, (exprtypes.StringType(),), exprtypes.StringType())
        self.eval_children = lambda a: f'AVG({a})'

class CypherInstantiator(semantics_types.InstantiatorBase):
    def __init__(self):
        super().__init__('cypher')
        self.lia_instantiator = semantics_lia.LIAInstantiator()
        
        self.function_types = {
            'match': (exprtypes.GraphType(), exprtypes.StringType()),
            'matchr': (exprtypes.GraphType(), exprtypes.StringType()),
            'return': (exprtypes.GraphType(), exprtypes.StringType()),
            'filter': (exprtypes.GraphType(), exprtypes.StringType()),
            'createNodePattern': (exprtypes.StringType(), exprtypes.StringType()),
            'createEdgePattern': (exprtypes.StringType(), exprtypes.StringType(), exprtypes.StringType()),
            'createPathPattern': (exprtypes.StringType(), exprtypes.StringType(), exprtypes.StringType()),
            'createExpressionList': (exprtypes.StringType(), exprtypes.StringType()),
            'createReturnList': (exprtypes.StringType(), exprtypes.StringType()),
            'getProperty': (exprtypes.StringType(), exprtypes.StringType()),
            'eadd': (exprtypes.StringType(), exprtypes.StringType()),
            'esub': (exprtypes.StringType(), exprtypes.StringType()),
            'emul': (exprtypes.StringType(), exprtypes.StringType()),
            'ediv': (exprtypes.StringType(), exprtypes.StringType()),
            'equal': (exprtypes.StringType(), exprtypes.StringType()),
            'ene': (exprtypes.StringType(), exprtypes.StringType()),
            'elt': (exprtypes.StringType(), exprtypes.StringType()),
            'elte': (exprtypes.StringType(), exprtypes.StringType()),
            'pand': (exprtypes.StringType(), exprtypes.StringType()),
            'por': (exprtypes.StringType(), exprtypes.StringType()),
            'COUNT': (exprtypes.StringType(),),
            'SUM': (exprtypes.StringType(),),
            'MAX': (exprtypes.StringType(),),
            'MIN': (exprtypes.StringType(),),
            'AVG': (exprtypes.StringType(),)
        }
        
        self.function_instances = {
            'match': Match(),
            'matchr': MatchR(),
            'return': Return(),
            'filter': Filter(),
            'createNodePattern': CreateNodePattern(),
            'createEdgePattern': CreateEdgePattern(),
            'createPathPattern': CreatePathPattern(),
            'createExpressionList': CreateExpressionList(),
            'createReturnList': CreateReturnList(),
            'getProperty': GetProperty(),
            'eadd': Add(),
            'esub': Sub(),
            'ediv': Div(),
            'emul': Mul(),
            'equal': Equal(),
            'ene': Ne(),
            'elt': Lt(),
            'elte': Lte(),
            'pand': And(),
            'por': Or(),
            'COUNT': Count(),
            'SUM': Sum(),
            'MIN': Min(),
            'MAX': Max(),
            'AVG': Avg()
        }
    
    def _get_canonical_function_name(self, function_name):
        return function_name
        
    def _do_instantiation(self, function_name, mangled_name, arg_types):
        if function_name not in self.function_types:
            return None

        # print(f"Things {arg_types} and {self.function_types[function_name]} and {function_name}")
        assert arg_types == self.function_types[function_name]
        return self.function_instances[function_name]