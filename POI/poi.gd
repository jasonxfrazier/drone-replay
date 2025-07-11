# POI.gd
extends Area2D

@export var poi_id: int = 0

@onready var cs: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

func _ready() -> void:
	add_to_group("POI")
	connect("body_entered", Callable(self, "_on_body_entered"))

	if label != null:
		# show POI ID; position manually in the 2D editor
		label.text = "%d" % poi_id

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("setup"):
		print("🚩 Drone %d intersected POI %d" % [body.drone_id, poi_id])
