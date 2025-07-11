# DroneManager.gd
extends Node2D

@export var map_node_path: NodePath
@export var default_csv_path: String   = "res://CSVs/path/flight_data.csv"
@export var drone_scene:    PackedScene
@export var time_scale:     float      = 10.0

@onready var map_node: Node2D       = _get_map_node()
@onready var timectrl              = TimeController

func _get_map_node() -> Node2D:
	if map_node_path != NodePath(""):
		var n = get_node_or_null(map_node_path)
		if n and n is Node2D:
			return n
		push_error("map_node_path invalid: %s" % map_node_path)
	if get_parent().has_node("Map"):
		return get_parent().get_node("Map") as Node2D
	var found = get_tree().get_root().find_node("Map", true, false)
	if found and found is Node2D:
		return found as Node2D
	push_error("Map node not found—please assign map_node_path")
	return self

func _ready() -> void:
	# Choose CSV path
	var path: String
	if Config.flight_csv_path != "":
		path = Config.flight_csv_path
	else:
		path = default_csv_path

	print("🔍 DroneManager loading CSV:", path)
	if not FileAccess.file_exists(path):
		push_error("CSV not found: %s" % path)
		return

	# Read and split
	var text : String = FileAccess.open(path, FileAccess.READ).get_as_text()
	var lines: Array  = text.strip_edges(true, true).split("\n")
	if lines.size() <= 1:
		push_error("No data in CSV")
		return
	lines.remove_at(0)  # header

	# Prepare for parsing
	var raw_ts: Array = []
	for line in lines:
		raw_ts.append(line.split(",")[1])
	var base        : int   = Time.get_unix_time_from_datetime_string(raw_ts[0])

	# Build tracks and find max time
	var tracks      : Dictionary = {}
	var max_time_off: float      = 0.0
	for line in lines:
		var f      = line.split(",")
		var id     = f[0].to_int()
		var ts     = Time.get_unix_time_from_datetime_string(f[1])
		var t_off  = float(ts - base)
		if t_off > max_time_off:
			max_time_off = t_off
		var lat    = f[2].to_float()
		var lon    = f[3].to_float()
		var pos    = map_node.latlon_to_world(lat, lon)

		if not tracks.has(id):
			tracks[id] = []
		tracks[id].append({ "pos": pos, "time": t_off })

	# Initialize TimeController
	timectrl.set_time_range(0.0, max_time_off)
	timectrl.playback_speed = time_scale
	timectrl.pause()

	# Debug track lengths
	for id in tracks.keys():
		print("🛩️ Track for Drone", id, "points:", tracks[id].size())

	# Spawn drones
	if drone_scene == null:
		push_error("drone_scene not assigned in Inspector")
		return

	for id in tracks.keys():
		print("🚀 Spawning Drone", id)
		var inst = drone_scene.instantiate()
		if inst == null:
			push_error("Failed to instantiate drone_scene")
			continue
		inst.name = "Drone%d" % id
		add_child(inst)
		if inst.has_method("setup"):
			inst.setup(tracks[id], id)
		else:
			push_error("Instanced scene has no setup() method")
