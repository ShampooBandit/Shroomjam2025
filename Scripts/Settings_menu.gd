extends Control

var master_bus = AudioServer.get_bus_index("Master")
@onready var slider := $GridContainer/HSlider

func _ready() -> void:
	slider.value = Settings.main_volume

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/title.tscn")


func _on_h_slider_value_changed(value):
	Settings.main_volume = value
	AudioServer.set_bus_volume_linear(master_bus, value)

func _on_check_box_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
