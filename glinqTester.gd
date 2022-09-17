extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


#Gauranteed so no length checks are needed.
func _sort(x,y):
	return x < y

# Called when the node enters the scene tree for the first time.
func _ready():	
	var random_enumerator = GLinq.new(GLinq.InfiniteEnumerator.new()).take(5)
	print(random_enumerator.Array())
	
	var sort_with_str = random_enumerator.sort("x,y => x < y")
	print(sort_with_str.Array())
	
	var fr = funcref(self, "_sort")
	var sort_with_funcref = random_enumerator.sort(fr);
	print(sort_with_funcref.Array())
	
	#most likely the best way for built in types
	#Any boolean will work
	var sort_with_godot = random_enumerator.sort(true)
	print(sort_with_godot.Array())
	
	var sort_with_godot2 = random_enumerator.sort(false)
	print(sort_with_godot2.Array())
	




"""

	var g:GLinq = GLinq.new([1,2,3])
	var b = g.First() #1
	print("First: " + str(b))
	
	var g2 = g.from([4]) #[[1,4],[2,4],[3,4]]
	b = g2.Last() # [3,4]
	print("Last: " + str(b))

	var g3 = g.where("x => x&1 == 1").Array() #Is odd?
	print(g3);
	
	var funcRef = funcref(self, "is_odd")
	var g4 = g.where(funcRef).Array()
	print(g4)
	
	var double = g.select("x => x * 2").Array()
	print(double)
	double = g2.select("s,k => [s * 2, k * 2]").Array()
	print(double)
	
	var sum_each = g2.select("s,k => k+s").Array()
	print(sum_each)
	
	var vectorArray = [Vector2.ZERO, Vector3.LEFT, {"x":4,"y":5}] 
	var x_array = GLinq.new(vectorArray).select("x => x.x")
	#var z_array = GLinq.new(vectorArray).select("x => x.z").Array(); #Will fail since dictionary and vector2 doesn't support z
	print(x_array.Array()) #[0, -1, 4 ]
	
	
	var g5 = GLinq.new(GLinq.InfiniteEnumerator.new())
	var take = g5.take(10)
	var even_Glinq = take.where("x => x & 1 == 0");
	print(even_Glinq.Array()) #Completely random but should average towards length of 5
	
	var skip = take.skip(4);
	print(skip.Array()) #Keeps bottom 6 elements
	
	var _max = g.Max() #3
	print(_max)
	
	var _bad_max = g.Max("l,r => l > r")
	print(_bad_max) #reversed so it gives back 1
	
	var _min = g.Min() #3
	print(_min)
	
	var g6 = GLinq.new([Vector2.ONE, Vector2.ZERO, Vector2.ONE * -1])
	var sorted = g6.sort()
	var sorted2 = g6.sort("x,y => x > y")
	print(sorted.Array())
	print(sorted2.Array())
	print(sorted.Max())
	print(sorted.Min())

"""
