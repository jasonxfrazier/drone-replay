extends Node2D

@export var min_lat: float = -81.011678823
@export var max_lat: float = -80.862313031
@export var min_lon: float = 35.159845160
@export var max_lon: float = 35.258377660

@onready var map_sprite: Sprite2D = $Sprite2D

func latlon_to_world(lat: float, lon: float) -> Vector2:
	# size of the map image in pixels
	var size: Vector2 = map_sprite.texture.get_size()
	# fraction across the map bounds
	var fx: float = (lon - min_lon) / (max_lon - min_lon)
	# inverted fraction for Y so north is up
	var fy: float = (max_lat - lat) / (max_lat - min_lat)
	# local pixel position within the sprite
	var local_pos: Vector2 = Vector2(fx * size.x, fy * size.y)
	# since Centered = false, global_position is the top-left
	var top_left: Vector2 = map_sprite.global_position
	return top_left + local_pos
