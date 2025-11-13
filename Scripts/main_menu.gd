extends Control

@onready var song = preload("res://SFX/title.ogg")
@onready var bg : AnimatedSprite2D = $Background
var timer : int = randi_range(15, 60)
var player : AudioStreamPlayer

func _ready():
	player = SoundPlayer.title_music(song)

func _physics_process(_delta: float) -> void:
	timer -= 1
	
	if timer <= 0:
		if bg.animation == "light_high":
			bg.play("light_low")
			timer = randi_range(15, 60)
		else:
			bg.play("light_high")
			timer = randi_range(15, 60)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_start_game_button_pressed() -> void:
	player.stop()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_gallery_button_pressed() -> void:
	player.stop()
	get_tree().change_scene_to_file("res://Scenes/gallery.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
