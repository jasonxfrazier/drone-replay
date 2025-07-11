# res://ReplayUI.gd
extends Control

@onready var back_btn: Button = $ControlsVBox/ButtonRow/StepBackwardBtn
@onready var play_btn: Button = $ControlsVBox/ButtonRow/PlayPauseBtn
@onready var forward_btn: Button = $ControlsVBox/ButtonRow/StepForwardBtn
@onready var time_label: Label = $ControlsVBox/ButtonRow/TimeLabel
@onready var slider: HSlider = $ControlsVBox/TimeSlider
@onready var timectrl = TimeController

func _ready() -> void:
	# Initialize slider range from TimeController
	slider.min_value = timectrl.start_time
	slider.max_value = timectrl.end_time
	slider.step      = timectrl.step_size
	slider.value     = timectrl.current_time

	# Hook up buttons and slider
	back_btn.connect("pressed",       Callable(self, "_on_step_backward"))
	play_btn.connect("pressed",       Callable(self, "_on_play_pause_pressed"))
	forward_btn.connect("pressed",    Callable(self, "_on_step_forward"))
	slider.connect("value_changed",   Callable(self, "_on_slider_changed"))

	# Display initial time
	_update_time_label()

	# Start processing so we can update label even when playing
	set_process(true)

func _process(delta: float) -> void:
	# Sync UI when playing
	if timectrl.is_playing:
		slider.value = timectrl.current_time
		_update_time_label()

func _on_play_pause_pressed() -> void:
	if timectrl.is_playing:
		timectrl.pause()
		play_btn.text = "Play"
	else:
		timectrl.play()
		play_btn.text = "Pause"

func _on_step_backward() -> void:
	timectrl.step_backward()
	slider.value = timectrl.current_time
	_update_time_label()

func _on_step_forward() -> void:
	timectrl.step_forward()
	slider.value = timectrl.current_time
	_update_time_label()

func _on_slider_changed(value: float) -> void:
	timectrl.current_time = value
	_update_time_label()

func _update_time_label() -> void:
	# Display as mm:ss
	var total: int = int(timectrl.current_time)
	var mins:  int = total / 60
	var secs:  int = total % 60
	time_label.text = "%02d:%02d" % [mins, secs]
