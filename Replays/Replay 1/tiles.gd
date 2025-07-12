extends Node2D

var drag = false
var drag_start = Vector2()
var camera_start = Vector2()

@onready var camera := $Camera2D

var dragging := false
var drag_origin := Vector2()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				drag_origin = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 0.9
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1

	elif event is InputEventMouseMotion and dragging:
		camera.position -= event.relative
