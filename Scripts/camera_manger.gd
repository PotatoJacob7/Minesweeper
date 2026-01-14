extends Node2D

@onready var cam := $Camera2D

@export var ZoomSpeed := 0.1
@export var MinZoom := 1.0
@export var MaxZoom := 4.0
@export var DragSpeed := 1.0

var IsPressed := false
var e := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and IsPressed:
		e = event.relative * DragSpeed
		cam.position -= e
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			IsPressed = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam.zoom = Vector2.ONE * max(MinZoom, cam.zoom.x - ZoomSpeed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam.zoom = Vector2.ONE * min(MaxZoom, cam.zoom.x + ZoomSpeed)
