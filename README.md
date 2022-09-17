# GLinq

## What is This
A [**greedy**](https://dotnettutorials.net/lesson/deferred-execution-vs-immediate-execution-in-linq/) method only version of C#'s LINQ built for GDScript.



## Why does it exist
I wanted the ease of LINQ syntax in GDScript when I am manipulating arrays.

Also, I thought it would be fun to implement it. I learned a lot from this project but it seems to work better than expected so I thought I would share it. 

## How does it work
As said before it is based on C#'s LINQ. So, just like LINQ, it is required that whatever you want to enumerate must extend IEnumerator.

For more details on [Microsoft Enumerator Implementation](https://learn.microsoft.com/en-us/dotnet/api/system.collections.ienumerator?view=net-6.0#remarks)
	
	class IEnumerator:
	#Override these functions for your enumerator
	func move_next() -> bool:
		return true
	
	var current setget ,_get_current
	func _get_current():
		return 0
	
	func reset():
		pass

	
Example implementation of an infinite enumerator below

	class InfiniteEnumerator extends IEnumerator:
		func move_next():
			return true
		
		func _get_current():
			return randi()
			
		func reset():
			pass
		
		func _init():
			randomize()
			
From there all the normal LINQ functions are implemented and I included string lambdas for people who don't want to create funcRefs, I know I don't like to make them all the time.

By default, all built in **Array** types are supported by the built-in Enumerator class implicitly. Also, it duplicates anything passed to it so changes made to the original has no effect on the Enumerator. If you attempt to manipulate from outside it is *undefined behavior*.

	const VALID_TYPES = [TYPE_VECTOR3_ARRAY, TYPE_VECTOR2_ARRAY,TYPE_STRING_ARRAY,TYPE_REAL_ARRAY, TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_COLOR_ARRAY, TYPE_RAW_ARRAY]
	#Yeah I know it could have been implemented as (>= TYPE_ARRAY) and (< TYPE_MAX).
	
### Creating a GLinq Object
The GLinq class is the wrapper around the syntax that allows anything that is an IEnumerator be used.

camelCase GLinq functions generate new GLinqs but PascalCase Glinq functions return data

	#Array types
	var glinqNum = GLinq.new([1..100]) 
	var glinqComplex = GLinq.new([Vector2.ZERO, Vector3.ZERO, {"x": 10, "y": "hat in time"}])
	
	#Any IEnumerator
	var glinqInf = GLinq.new(InfiniteEnumerator.new()) 
	
### How to use From


Just pass any built in array type or anything that implements IEnumerator as a input.

	var glinqNum2 = GLinq.new().from([10,20,30]) 
	
	#Has column Name,Age\
	class DatabaseEnumerator extends IEnumerator:
		
		func _get_current():
			#returns data from the database as a dictionary
			
		func move_next():
			#check if the database has more data to send and moves to it
			
		func reset():
			#move to beginning of the data base
	
	[{Person: "J", Age: 10 },{Person: "K", Age: 23 }, {Person: "L", Age: 7 }]
	var glinqFinite = GLinq.new().from(DatabaseEnumerator.new()) 
	
When used with a with a second array it immediately combines them
	
	#[[10,2], [20,2] ,[30,2]]
	var glinqNum3 = gLinqNum2.from([2,1]) 
	


### How to use select
It allows the Enumerator to manipulate the data and output put it based on the current inputs it has access to.

It can take in at **most** as many inputs as it has **froms** so two **froms** means a max of 2 inputs.

A simple expression made up inputs from from can be used to manipulate(map) the data. Global variables can be used if the object with access to the global variable is passed.

It can also use a FuncRef but the FuncRef must take in a array as input if multiple froms are used or any data type if no from are used after the initialization. When using FuncRef, the base parameter doesn't do anything.

#### Example 1 - Complex Types

	var glinqComplex = GLinq.new([Vector2.ZERO, Vector3.ZERO, {"x": 10, "y": "hat in time"}])
	
	#[0, 0, 10]
	var x_array = gLinqComplex.select("a => a.x")
	
#### Example 2 - String Lambdas

	var glinq_num_2 = GLinq.new([10,3,2])
	print(glinq_num_2.Array()) #[10, 3, 2]
	
	
	var glinqNum3 = glinq_num_2.from([2,3])
	print(glinqNum3.Array()) #[[10, 2], [10, 3], [3, 2], [3, 3], [2, 2], [2, 3]]
	
	var glinq_num_2_plus_3 = glinqNum3.select("x,y => x + y")
	print(glinq_num_2_plus_3.Array()) #[12, 13, 5, 6, 4, 5]
	
	#only support simple expressions
	#The first possible expression 
	var glinq_num_2_divide_3 = glinqNum3.select("x,y => x/y if y != 2 else x*y")
	print(glinq_num_2_divide_3.Array())  #[5, 3, 1, 1, 1, 0]

#### Example 3 - More
	# Called when the node enters the scene tree for the first time.
	func _ready():	
		var glinq_num_2 = GLinq.new([10,3,2])
		var glinqNum3 = glinq_num_2.from([2,3])
		#[[10, 2], [10, 3], [3, 2], [3, 3], [2, 2], [2, 3]]
		print(glinqNum3.Array())
		_func_ref(glinqNum3)
		one_more_example(glinqNum3)

	
	func working_2_divide_3(array:Array):
		var x = array[0]
		var y = array[1]
		return x/y if y != 2 else x * y;

	func _func_ref(_gLinq:GLinq) -> GLinq:
		var fr = funcref(self, "working_2_divide_3")
		var gLinq = _gLinq.select(fr);
		
		#[20, 3, 6, 1, 4, 0]
		print(gLinq.Array())
		return gLinq

	
	const NEGA = -1 
	
	#Can access global variables of any object pass to it.
	#In this case it was self	
	func one_more_example(_gLinq:GLinq) -> GLinq:
		#Only the values needed need to be written for the lambda
		#Enums use 
		var gLinq:GLinq = _gLinq.select("x => x * NEGA", self);
		
		#[-10, -10, -3, -3, -2, -2]
		print(gLinq.Array())
		return gLinq;

### How to use Where
It works like select except all of it functions must return a boolean

If the result of the operation or true, the data is kept. Else, the data is dropped.

 

It is basically a filter for data.

	func is_odd(x):
		return x & 1 == 1;

	func is_2nd_odd(x:Array):
		return is_odd(x[1])
	
	func _ready():	
		var gLinq = GLinq.new([10,3,2])
		print(gLinq.Array()) #[10, 3, 2]
		
		#Even Only since it is not is_odd
		var glinq_is_not_odd = gLinq.where("x => !is_odd(x)", self)
		print(glinq_is_not_odd.Array()) #[10, 2]
		
		var fr = funcref(self, "is_odd")
		var glinq_fr = gLinq.where(fr, self)
		print(glinq_fr.Array()) #[3]
			
		var gLinq2 = gLinq.from([4,1,3])
		
		#[[10, 4], [10, 1], [10, 3], [3, 4], [3, 1], [3, 3], [2, 4], [2, 1], [2, 3]]
		print(gLinq2.Array()) 
		
		var glinq_no_sames = gLinq2.where("x,y => x != y");
		
		#[[10, 4], [10, 1], [10, 3], [3, 4], [3, 1], [2, 4], [2, 1], [2, 3]]
		print(glinq_no_sames.Array()) 
		
		var fr2 = funcref(self, "is_2nd_odd")
		var gLinq_as_long_as_2nd_element_is_even = gLinq2.where(fr2);
		
		#[[10, 1], [10, 3], [3, 1], [3, 3], [2, 1], [2, 3]]
		print(gLinq_as_long_as_2nd_element_is_even.Array()) 
		
### How to use Sort
Like where it can use funcRefs and string lambdas. Also, both must evaluate to a boolean value. Unlike **where**, when the function provided to **sort**  is false, the current value is evaluated to be "less than" and vice_versa for true. All functions will always receive two values. Also (again), the function will send two values so no dealing with arrays.

As a special case, if the first parameter is passed a boolean, it will attempt to use the built in sort function of Arrays provided by Godot. It is the fastest and preferred way.

Non Godot Sort algorithm uses **insertion sort** 

	func _sort(x,y):
		return x < y

	func _ready():	
		var random_enumerator = GLinq.new(GLinq.InfiniteEnumerator.new()).take(5)
		print(random_enumerator.Array())
		#[2408051404, 564418085, 2770901885, 433009269, 1598326110]
		
		var sort_with_str = random_enumerator.sort("x,y => x < y")
		print(sort_with_str.Array())
		#[433009269, 564418085, 1598326110, 2408051404, 2770901885]
		
		var fr = funcref(self, "_sort")
		var sort_with_funcref = random_enumerator.sort(fr);
		print(sort_with_funcref.Array())
		#[433009269, 564418085, 1598326110, 2408051404, 2770901885]
		
		#most likely the best way for built in types
		#Any Boolean will work
		var sort_with_godot = random_enumerator.sort(true)
		print(sort_with_godot.Array())
		#[433009269, 564418085, 1598326110, 2408051404, 2770901885]
		
		var sort_with_godot2 = random_enumerator.sort(false)
		print(sort_with_godot2.Array())
		#[433009269, 564418085, 1598326110, 2408051404, 2770901885]
	
### How to use Take
It takes the first n value , where n is the number of values request, and returns a new GLinq object with upto n items if the enumerator can provide those values.

This is important for infinite enumerators since they never end so you just take what you need and do work on your finite set of the infinite enumerator

	var gLinq = GLinq.new([1,3,4])
	
	var gLinq_take_2 = gLinq.take(2) 
	print(gLinq_take_2.Array()) # [1,3]
	
	var gLinq_take_5 = gLinq.take(5) 
	print(gLinq_take_5.Array()) # [1,3,4]
	
	
	
### How to use Skip
It sips the first n value , where n is the number of values request, and returns a new GLinq object with the initial n items removed

This is important for infinite enumerators since they never end so you just take what you need and do work on your finite set of the infinite enumerator

	var gLinq = GLinq.new([1,3,4])
	var gLinq_take_2 = gLinq.skip(2) # [4]
	print(gLinq_take_2.Array()) 
	var gLinq_take_5 = gLinq.skip(5) # []
	print(gLinq_take_5.Array()) 


### How to use Concat
It simply combines two **FINITE** enumerators together and return an new GLinq for the new Enumerator

	[1,2,3] + ["Doggy", false] = [1,2,3,"Doggy", false]


### Data functions
These functions extract the data out of the enumerator for the program to use.
All data functions use PascalCase to represent that they return data not another GLinq object.

Rec_Max, Rec_Min, Max, Min all function like sort they just return the a single item rather than a GLinq but the Rec functions are probably faster.

All functions will use the GLinq shown below:

	var gLinq = GLinq.new([1,["Fart","Burp"] 2, false, range(5)];
	
Function Name | Description | Example | Gotchas
---|---|---|---
First | Returns the first item in the enumerator, null or default value provided | var i = gLinq.First() # 1 | None
Last | Returns the last item in the enumerator, null or default value provided | 
Rec_Max | Gets the max value of the Enumerator | var i = gLinq.where("x => x is int").Rec_Max() # 2| Assumes that sort is going from least to greatest.
Max | Gets the max value of the Enumerator | var i = gLinq.select("x => len(str(x))").Max() # string length of ["Fart","Burp"]| Assumes that sort is going from least to greatest.
Rec_Min | Gets the minimum value of the Enumerator | var i = gLinq.where("x => x is int").Rec_Max() # 1| Assumes that sort is going from least to greatest.
Min | Gets the minimum value of the Enumerator | var i = gLinq.select("x => len(str(x))").Min() # 1| Assumes that sort is going from least to greatest.
Any | Returns true if the enumerator has any values | gLinq.Any() #true | Always returns a bool
Count | Returns the length as an int of the enumerator | #gLinq.Count() # 5  | Always returns an int
Array | Converts the Enumerator into an index-able array. | gLinq.Array() # [1,["Fart","Burp"] 2, false, range(5)] | Always returns an Array

## Glitches
1. Empty Enumerators make all subsequent calls empty no matter what. It will probably be fixed by moving Any() into the IEnumerator so that if there is Any() return the original GLinq.
