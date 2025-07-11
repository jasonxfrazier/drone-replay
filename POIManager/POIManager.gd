extends Node2D

@export var map_node_path: NodePath
@export var default_csv_path: String = "res://CSVs/poi/POI_Data_CSV__4_POIs_.csv"
@export var poi_scene: PackedScene

@onready var map_node: Node2D = _get_map_node()

func _get_map_node() -> Node2D:
	# 1) If the user specified a map_node_path, try it
	if map_node_path != NodePath(""):
		var candidate = get_node_or_null(map_node_path)
		if candidate and candidate is Node2D:
			return candidate as Node2D
		push_error("map_node_path set but not found or not a Node2D: %s" % map_node_path)
	# 2) Fallback to sibling called "Map"
	if get_parent().has_node("Map"):
		return get_parent().get_node("Map") as Node2D
	# 3) Broad search for any node named "Map"
	var found = get_tree().get_root().find_node("Map", true, false)
	if found and found is Node2D:
		return found as Node2D
	# 4) Give up
	push_error("Map node not found—please assign map_node_path")
	return self  # avoid nulls

func _ready() -> void:
	# Choose CSV: user-picked or default
	var path: String
	if Config.poi_csv_path != "":
		path = Config.poi_csv_path
	else:
		path = default_csv_path

	# Load the CSV
	if not FileAccess.file_exists(path):
		push_error("CSV not found at %s" % path)
		return
	var text: String = FileAccess.open(path, FileAccess.READ).get_as_text()
	var lines: Array = text.strip_edges(true, true).split("\n")
	if lines.size() <= 1:
		push_error("CSV has no data")
		return
	lines.remove_at(0)

	# Spawn each POI
	for line in lines:
		var f = line.split(",")
		var id: int      = f[0].to_int()
		var label: String = f[1]
		var lat: float   = f[2].to_float()
		var lon: float   = f[3].to_float()

		var world_p: Vector2 = map_node.latlon_to_world(lat, lon)

		var poi = poi_scene.instantiate() as Area2D
		if poi == null:
			push_error("Failed to instantiate poi_scene")
			continue
		poi.name = "POI%d" % id
		poi.global_position = world_p
		poi.set("poi_id", id)
		poi.set("poi_name", label)
		add_child(poi)
