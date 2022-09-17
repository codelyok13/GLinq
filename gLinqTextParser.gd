extends Object

onready var expression = Expression.new()

func parse(script:String):
	#s,i => simple_expression
	# simple_expression,["s","i","index"]
	var lr:Array = script.split("=>");
	var array:Array = str(lr[0]).replace(" ","").split(",")
	
	if not "index" in array:
		array.push_back("index")
	
	var str_expression:String = str(lr[1]).replace(" ","");
	expression.parse(str_expression, array)
	
func execute_1(first,index, base = null):
	return expression.execute([first,index], base);

func execute_bool(first,second, base = null):
	return expression.execute([first,second], base);
