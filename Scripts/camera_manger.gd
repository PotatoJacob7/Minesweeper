extends Node2D
class_name CamManager

@onready var cam := $Camera2D

@export var ZoomSpeed := 0.1
@export var MinZoom := 1.0
@export var MaxZoom := 4.0
@export var DragSpeed := 1.0

var CanScroll := true
var IsMiddlePressed := false
var IsLeftPressed := false
var MovingWIndow := false
var e := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and IsMiddlePressed:
		e = event.relative * DragSpeed
		cam.position -= e
	elif event is InputEventMouseMotion and IsLeftPressed and MovingWIndow:
		e = event.relative * DragSpeed
		get_window().position += Vector2i(e)
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE: IsMiddlePressed = event.pressed
			MOUSE_BUTTON_LEFT: IsLeftPressed = event.pressed
			MOUSE_BUTTON_WHEEL_DOWN:
				if CanScroll:
					cam.zoom = Vector2.ONE * max(MinZoom, cam.zoom.x - ZoomSpeed)
			MOUSE_BUTTON_WHEEL_UP:
				if CanScroll:
					cam.zoom = Vector2.ONE * min(MaxZoom, cam.zoom.x + ZoomSpeed)
	elif event is InputEventKey:
		if Input.is_action_just_pressed("toggle move"):
			MovingWIndow = !MovingWIndow
