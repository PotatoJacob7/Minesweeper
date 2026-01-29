extends Node

const RATIO = 1080.0 / 1920.0


func _ready():
	get_window().connect("size_changed", test)

func test():
	DisplayServer.window_set_size(Vector2i(1920,1080))

@onready var defaultSize = get_window().size
@onready var CurrentSize = get_window().size
@onready var Scale = CurrentSize / defaultSize
@onready var PreviousSize = CurrentSize
 
var ignore_Y = false
var ignore_X = false
 
#func set_window_aspect_ratio():
	#CurrentSize = get_window().size
	#Scale = CurrentSize / defaultSize
 #
	#if CurrentSize.x != PreviousSize.x && ignore_X == false:#Tests if the window is being resized in the x axis and not the y
		#DisplayServer.window_set_size(Vector2i(1920,1080))
		#OS.set_window_size(Vector2(CurrentSize.x, defaultSize.y * Scale.x))#Scales the y axis by the same factor as x
		#ignore_Y = true#Makes sure both pieces of code dont run at the same time
	#elif CurrentSize.x == PreviousSize.x && ignore_X == true:#Stops ignoring X
		#ignore_X = false
 #
	#if CurrentSize.y != PreviousSize.y && ignore_Y == false:#Tests if the window is being resized in the y axis and not the x
		#OS.set_window_size(Vector2(defaultSize.x * Scale.y, CurrentSize.y))#Scales the x axis by the same factor as y
		#ignore_X = true#Makes sure both pieces of code dont run at the same time
	#elif CurrentSize.y == PreviousSize.y && ignore_Y == true:#Stops ignoring Y
		#ignore_Y = false
 #
	#if OS.get_window_position().y < 0:#Prevents the title bar from going off screen
		#OS.set_window_position(Vector2(OS.get_window_position().x, 0))
 #
	#if CurrentSize < defaultSize / 4:#Prevents the window from being too small
		#OS.set_window_size(defaultSize / 4)
 #
	#PreviousSize = CurrentSize #This line MUST go at the end
