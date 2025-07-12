# MainMenu.gd — attach to root Control of MainMenu.tscn
extends Control

# UI nodes
var flight_btn    : Button
var flight_label  : Label
var poi_btn       : Button
var poi_label     : Label
var play_btn      : Button
var flight_dialog : FileDialog
var poi_dialog    : FileDialog

# Parallax background
@export var bg_sprite_path: NodePath = "$Map"
@onready var bg_sprite: Sprite2D = get_node_or_null(bg_sprite_path) as Sprite2D
var bg_base_pos: Vector2
@onready var parallax: Parallax2D = $Parallax2D
var parallax_strength: float = 0.07 

func _ready() -> void:
	# fetch UI elements by path
	flight_btn    = get_node_or_null("VBoxContainer/FlightHBox/FlightBrowse")     as Button
	flight_label  = get_node_or_null("VBoxContainer/FlightHBox/FlightPathLabel")  as Label
	poi_btn       = get_node_or_null("VBoxContainer/POIHBox/POIBrowse")           as Button
	poi_label     = get_node_or_null("VBoxContainer/POIHBox/POIPathLabel")        as Label
	play_btn      = get_node_or_null("VBoxContainer/PlayHBox/PlayButton")         as Button
	flight_dialog = get_node_or_null("FlightFileDialog")                          as FileDialog
	poi_dialog    = get_node_or_null("POIFileDialog")                             as FileDialog

	# record base position for parallax
	if bg_sprite:
		bg_base_pos = bg_sprite.position

	# validate required nodes
	if not flight_btn:
		push_error("FlightBrowse button not found in scene tree")
	if not flight_dialog:
		push_error("FlightFileDialog not found in scene tree")

	# configure flight file dialog
	if flight_dialog:
		flight_dialog.access    = FileDialog.ACCESS_FILESYSTEM
		flight_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		flight_dialog.clear_filters()
		flight_dialog.add_filter("*.csv ; CSV Files")
		flight_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		flight_dialog.connect("file_selected", Callable(self, "_on_flight_selected"))

	# configure POI file dialog
	if poi_dialog:
		poi_dialog.access    = FileDialog.ACCESS_FILESYSTEM
		poi_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		poi_dialog.clear_filters()
		poi_dialog.add_filter("*.csv ; CSV Files")
		poi_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		poi_dialog.connect("file_selected", Callable(self, "_on_poi_selected"))

	# connect button signals
	if flight_btn:
		flight_btn.connect("pressed", Callable(self, "_on_flight_browse"))
	if poi_btn:
		poi_btn.connect("pressed", Callable(self, "_on_poi_browse"))
	if play_btn:
		play_btn.connect("pressed", Callable(self, "_on_play"))

	# enable processing for parallax
	set_process(true)

func _process(_delta: float) -> void:
	# parallax the background opposite mouse movement
	var vp_size = get_viewport().get_visible_rect().size
	var mouse   = get_viewport().get_mouse_position()
	var center  = vp_size * 0.5

	# mouse offset from center, scaled down
	var raw_offset: Vector2 = (mouse - center) * parallax_strength

	# apply it directly to Parallax2D.scroll_offset
	parallax.scroll_offset = raw_offset

# open flight CSV selector
func _on_flight_browse() -> void:
	if flight_dialog:
		flight_dialog.popup_centered()

# open POI CSV selector
func _on_poi_browse() -> void:
	if poi_dialog:
		poi_dialog.popup_centered()

# store selected flight CSV path
func _on_flight_selected(path: String) -> void:
	Config.flight_csv_path = path
	if flight_label:
		flight_label.text = path

# store selected POI CSV path
func _on_poi_selected(path: String) -> void:
	Config.poi_csv_path = path
	if poi_label:
		poi_label.text = path

# start replay scene
func _on_play() -> void:
	if Config.flight_csv_path == "":
		push_error("Please select a flight CSV before playing.")
		return
	get_tree().change_scene_to_file("res://Replays/Replay 1/replay1.tscn")
