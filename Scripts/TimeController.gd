# res://TimeController.gd
extends Node

# the simulation’s time bounds
var start_time:   float = 0.0
var end_time:     float = 0.0

# current playback time and controls
var current_time:   float = 0.0
var playback_speed: float = 1.0
var is_playing:     bool  = false
var step_size:      float = 1.0   # seconds per step

func _process(delta: float) -> void:
	if is_playing:
		current_time = clamp(current_time + delta * playback_speed, start_time, end_time)

func play() -> void:
	is_playing = true

func pause() -> void:
	is_playing = false

func toggle_play_pause() -> void:
	is_playing = !is_playing

func step_forward() -> void:
	is_playing = false
	current_time = clamp(current_time + step_size, start_time, end_time)

func step_backward() -> void:
	is_playing = false
	current_time = clamp(current_time - step_size, start_time, end_time)

func set_time_range(start_t: float, end_t: float) -> void:
	start_time   = start_t
	end_time     = end_t
	current_time = start_t
