from enum import Enum

from . import graph

class FunctionType(Enum):
    ARITHMETIC = 1
    AGGREGATOR = 2

class BaseFunction(object):
    '''
    Base class representing all of the operations that we can call on Expressions
    '''

    def __init__(self, function_type, function_name):
        self.function_type = function_type
        self.function_name = function_name

    def evaluate(self, arguments):
        raise NotImplementedError('Please implement me in the child class')
    
    def validate_arguments(self, arguments):
        raise NotImplementedError('Please implement me in the child class')

def is_number(value):
    try:
        float(value)
    except (ValueError, TypeError):
        return False
    
    return True

def is_CypherOutputType(item):
    return isinstance(item, CypherOutputType)

# ARITHMETIC OPERATIONS
class Addition(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'ADD')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = float(arguments[0]) + float(arguments[1])
        return int(val) if int(val) == val else val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        
        return is_number(arguments[0]) and is_number(arguments[1])

class AdditionReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'ADDRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType('', '+', [], arguments[0], arguments[1])
        return val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[0]) and is_CypherOutputType(arguments[1])

class Subtraction(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'SUB')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = float(arguments[0]) - float(arguments[1])
        return int(val) if int(val) == val else val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        
        return is_number(arguments[0]) and is_number(arguments[1])

class SubtractionReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'SUBRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType('', '-', [], arguments[0], arguments[1])
        return val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[0]) and is_CypherOutputType(arguments[1])

class Division(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'DIV')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = round(float(arguments[0]) / float(arguments[1]), 5)
        return int(val) if int(val) == val else val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        
        return is_number(arguments[0]) and is_number(arguments[1])

class DivisionReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'DIVRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType('', '/', [], arguments[0], arguments[1])
        return val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[0]) and is_CypherOutputType(arguments[1])
    
class Multiplication(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'MUL')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = float(arguments[0]) * float(arguments[1])
        return int(val) if int(val) == val else val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        
        return is_number(arguments[0]) and is_number(arguments[1])
    
class MultiplicationReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.ARITHMETIC, 'MUL')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType('', '*', [], arguments[0], arguments[1])
        return val
    
    def validate_arguments(self, arguments):
        '''Must be two numbers as our result'''

        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[0]) and is_CypherOutputType(arguments[1])

# AGGREGATORS   
class Count(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'COUNT')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        return len(arguments)
    
    def validate_arguments(self, arguments):
        '''Make sure a non-null list'''

        return type(arguments) == list

class CountReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'COUNTRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType(arguments[0], 'count', arguments[1], None, None)
        return val
    
    def validate_arguments(self, arguments):
        '''Must be three numbers as our result'''
        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[1])

class Sum(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'SUM')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        return sum([float(x) for x in arguments])
    
    def validate_arguments(self, arguments):
        '''Must be a list of numbers for our case'''

        if type(arguments) != list or len(arguments) == 0:
            return False
        
        return all([is_number(x) for x in arguments])
    
class SumReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'SUMRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType(arguments[0], 'sum', arguments[1], None, None)
        return val
    
    def validate_arguments(self, arguments):
        '''Must be three numbers as our result'''
        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[1])

class Max(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'MAX')

    def evaluate(self, arguments):
        '''If it is a CypherType then we use id, else it is biggest number'''

        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        if isinstance(arguments[0], graph.CypherType):
            biggest, largest_id = None, None

            for cypher in arguments:
                if largest_id is None or str(cypher.get_property('element_id')) > str(largest_id):
                    biggest = cypher
                    largest_id = cypher.get_property('element_id')

            return biggest

        return max([float(x) for x in arguments])
    
    def validate_arguments(self, arguments):
        '''Must be a list of numbers, or CypherTypes'''

        if type(arguments) != list or len(arguments) == 0:
            return False
        
        return all([is_number(x) for x in arguments]) or all(isinstance(x, graph.CypherType) for x in arguments)

class MaxReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'MAXRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType(arguments[0], 'max', arguments[1], None, None)
        return val
    
    def validate_arguments(self, arguments):
        '''Must be three numbers as our result'''
        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[1])
    
class Min(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'Min')

    def evaluate(self, arguments):
        '''If it is a CypherType then we use id, else it is biggest number'''

        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        if isinstance(arguments[0], graph.CypherType):
            smallest, smallest_id = None, None

            for cypher in arguments:
                if smallest_id is None or str(cypher.get_property('element_id')) < str(smallest_id):
                    smallest = cypher
                    smallest_id = cypher.get_property('element_id')

            return smallest

        return min([float(x) for x in arguments])
    
    def validate_arguments(self, arguments):
        '''Must be a list of numbers, or CypherTypes'''

        if type(arguments) != list or len(arguments) == 0:
            return False
        
        return all([is_number(x) for x in arguments]) or all(isinstance(x, graph.CypherType) for x in arguments)

class MinReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'MINRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType(arguments[0], 'min', arguments[1], None, None)
        return val
    
    def validate_arguments(self, arguments):
        '''Must be three numbers as our result'''
        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[1])

class Avg(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'AVG')

    def evaluate(self, arguments):
        
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        return round(sum([float(x) for x in arguments]) / len(arguments), 5)
    
    def validate_arguments(self, arguments):
        '''Must have a list of numbers for average'''

        if type(arguments) != list or len(arguments) == 0:
            return False
        
        return all([is_number(x) for x in arguments])

class AvgReturn(BaseFunction):
    def __init__(self):
        super().__init__(FunctionType.AGGREGATOR, 'AVGRETURN')

    def evaluate(self, arguments):
        if not self.validate_arguments(arguments):
            raise ValueError('Invalid arguments given')
        
        val = graph.CypherOutputType(arguments[0], 'avg', arguments[1], None, None)
        return val
    
    def validate_arguments(self, arguments):
        '''Must be three numbers as our result'''
        if len(arguments) != 2:
            return False
        return True
        # return is_CypherOutputType(arguments[1])