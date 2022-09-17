extends Reference
#All algorithms are greedy so the name has 10(b3) meanings
#GdScriptLinq, GodotLinq and GreedyLinq
#Plans to make it deffered on in the works

class_name GLinq

class IEnumerator:
	#Override these functions for your enumerator
	func move_next() -> bool:
		return true
	
	#Once move next fails, get_current is undefined. It depends on how the user implements it
	var current setget ,_get_current
	func _get_current():
		return 0
	
	func reset():
		pass

class Enumerator extends IEnumerator:
	var _internal_collection:Array
	var _internal_index = -1
	var _internal_length

	const VALID_TYPES = [TYPE_VECTOR3_ARRAY, TYPE_VECTOR2_ARRAY,TYPE_STRING_ARRAY,TYPE_REAL_ARRAY, TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_COLOR_ARRAY, TYPE_RAW_ARRAY]

	func _init(array):
		var _array = array.duplicate(true)
		if typeof(_array) != TYPE_ARRAY:
			_array = Array(_array)
		_internal_collection = _array
		_internal_length = len(_array)
		
	static func is_valid_collection_type(object):
		return typeof(object) in VALID_TYPES;

	#Methods below must be implemented in your collection class to work with gLinq
	func move_next():
		if _internal_index + 1 < _internal_length:
			_internal_index += 1
			return true
		return false
		
	func reset():
		_internal_index = -1

	func _get_current():
		return _internal_collection[_internal_index]

#Example implementation of an infinite enumerator
class InfiniteEnumerator extends IEnumerator:
	func move_next():
		return true
	
	func _get_current():
		return randi()
		
	func reset():
		pass
	
	func _init():
		randomize()


var _internal_enumerator:IEnumerator = Enumerator.new([])

#Helper Functions
func parse(script:String) -> Expression:
	var expression = Expression.new()
	#argument => simple expression
	#s,i => str(s) + str(i)
	#simple_expression,["s","i"]
	
	var lr:Array = script.split("=>");
	
	var array:Array = str(lr[0]).replace(" ","").split(",");
	
	"""
		if length < number_of_args_to_parse:
			printerr("Not enough arguments to for this method")
			return null
		elif length > number_of_args_to_parse:
			print_debug("To many arguments! Other arguments are ignored. Max: " + str(number_of_args_to_parse))"""
	
	var str_expression:String = str(lr[1]).strip_edges();
	if expression.parse(str_expression, array) != OK:
		return null
	return expression;

func _init(data = null):
	if Enumerator.is_valid_collection_type(data):
		_internal_enumerator = Enumerator.new(data)
	elif data == null:
		return
	else:
		_internal_enumerator = data

#Functions that return data.
#If your not sure if the data is finite call take first
func First(default = null):
	_internal_enumerator.reset();
	if _internal_enumerator.move_next():
		return _internal_enumerator.current;
	return default

func Last(default = null):
	while _internal_enumerator.move_next():
		pass
	if _internal_enumerator.current != null:
		return _internal_enumerator.current
	return default

func rec_Max(fun = null, base = null):
	var array = []
	_internal_enumerator.reset()
	
	while _internal_enumerator.move_next():
		var value = _internal_enumerator.current
		if not _internal_enumerator.move_next():
			array.push_back(value)
			break;
		var value2 = _internal_enumerator.current
		var _bool:bool = false;
		if fun == null:
			_bool = value > value2
		elif typeof(fun) == TYPE_STRING:
			_bool = parse(fun).execute([value, value2], base)
		else:
			var _funcRef:FuncRef = fun
			_bool = _funcRef.call_func(value, value2)
		var output = value if _bool else value2
		array.push_back(output)
		
	if len(array) == 1:
		return array[0]
	else:
		return get_script().new(array).Max(fun, base)

func rec_Min(fun = null, base = null):
	if fun == null:
		fun = "l,r => l < r"
	return Max(fun, base);

func Max(fun = null, base = null):
	return sort(fun, base).Last()

func Min(fun = null, base = null):
	return sort(fun, base).First()

func Any() -> bool:
	_internal_enumerator.reset()
	return _internal_enumerator.move_next()

func Count()  -> int:
	return len(self.Array())

func Array() -> Array:
	var array:Array = []
	_internal_enumerator.reset()
	while _internal_enumerator.move_next():
		array.push_back(_internal_enumerator.current)
	return array
	pass

#Linq Functions
func from(data) -> GLinq:
	var _1:IEnumerator = _internal_enumerator
	var _2_temp = data
	if Enumerator.is_valid_collection_type(data):
		_2_temp = Enumerator.new(data)
	var _2:IEnumerator = _2_temp
	
	var array = []
	
	
	_1.reset()
	while _1.move_next():
		var temp = _1.current
		if Enumerator.is_valid_collection_type(temp):
			var _array:Array = temp
			while _2.move_next():
				var tempArray:Array = _array.duplicate(true)
				tempArray.append_array(_2.current)
				array.push_back(_2.current)
		else:
			while _2.move_next():
				array.push_back([temp,_2.current])
			_2.reset()
	return get_script().new(array);
	
func where(function, base = null) -> GLinq:
	_internal_enumerator.reset()
	var array = []
	match typeof(function):
		TYPE_STRING:
			var expression:Expression = parse(function)
			while _internal_enumerator.move_next():
				var value = _internal_enumerator.current
				var input = value if Enumerator.is_valid_collection_type(value) else [value]
				if expression.execute(input, base):
					array.push_back(value)
		_:
			var funcRef:FuncRef = function
			while _internal_enumerator.move_next():
				var value = _internal_enumerator.current
				if funcRef.call_func(value):
					array.push_back(value)
	return get_script().new(array);

func select(function, base = null) -> GLinq:
	_internal_enumerator.reset()
	var array = []
	while _internal_enumerator.move_next():
		var value = _internal_enumerator.current
		var output
		match typeof(function):
			TYPE_STRING:
				var input = value if Enumerator.is_valid_collection_type(value) else [value]
				var expr:Expression = parse(function)
				output = expr.execute(input, base)
			_:
				output = function.call_func(value)
		array.push_back(output)
	return get_script().new(array);

func take(count) -> GLinq:
	var array:Array = []
	
	_internal_enumerator.reset()
	while _internal_enumerator.move_next() and count != 0:
		array.push_back(_internal_enumerator.current)
		count = count - 1;
	return get_script().new(array);
	
func skip(count) -> GLinq:
	var array:Array = []
	
	_internal_enumerator.reset()
	while _internal_enumerator.move_next():
		if count != 0:
			count = count - 1
			continue
		array.push_back(_internal_enumerator.current)
	return get_script().new(array);

func sort(fun = null, base = null) -> GLinq:
	var array = []
	
	if fun is String:
		fun = parse(fun);
	elif fun is bool:
		array = self.Array()
		array.sort()
		return get_script().new(array);
			
		
	
	_internal_enumerator.reset()
	while _internal_enumerator.move_next():
		var current = _internal_enumerator.current
		
		if len(array) == 0:
			array.push_back(current)
			continue
		
		var insert:bool = false
		for i in range(0, len(array)):
			var value2 = array[i]
			if fun is Expression:
				var _exp:Expression = fun
				insert = _exp.execute([current, value2])
			elif fun is FuncRef:
				var fr:FuncRef = fun
				insert = fr.call_func(current, value2)
			else:
				insert = current < value2
			
			if insert:
				array.insert(i,current)
				break;
		
		if not insert:
			array.push_back(current)
		
	return get_script().new(array);
	pass

func concat(data) -> GLinq:
	if not Enumerator.is_valid_collection_type(data):
		return null
	var array = self.Array().append(data)
	return get_script().new(array);
	pass
