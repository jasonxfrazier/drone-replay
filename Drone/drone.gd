# Drone.gd
extends CharacterBody2D

var drone_id: int = 0
var points: Array = []

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var id_label: Label   = get_node_or_null("Label")   as Label
@onready var timectrl = TimeController

func setup(track: Array, id: int = 0) -> void:
	drone_id = id
	points = track
	if id_label != null:
		id_label.text = "%d" % drone_id
	if points.size() > 0:
		global_position = points[0]["pos"]

func _physics_process(delta: float) -> void:
	if points.size() < 2:
		return

	var t: float = timectrl.current_time

	# before the first waypoint
	if t <= points[0]["time"]:
		global_position = points[0]["pos"]
		return

	# after the last waypoint
	var last_idx: int = points.size() - 1
	if t >= points[last_idx]["time"]:
		global_position = points[last_idx]["pos"]
		return

	# find the current segment and interpolate
	for i in range(points.size() - 1):
		var p0: Dictionary = points[i]
		var p1: Dictionary = points[i + 1]
		var t0: float = p0["time"]
		var t1: float = p1["time"]
		if t >= t0 and t <= t1:
			var seg_dur: float = t1 - t0
			var alpha: float
			if seg_dur > 0.0:
				alpha = (t - t0) / seg_dur
			else:
				alpha = 1.0
			var pos0: Vector2 = p0["pos"]
			var pos1: Vector2 = p1["pos"]
			global_position = pos0.lerp(pos1, alpha)
			return
