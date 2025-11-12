class_name ZeldaSwordSlash extends Node2D

signal SlashFinished

var slash_sfx := preload("res://SFX/Zelda/sword_slash.wav")

var dir : int = 0
var damage : int = 1
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	SoundPlayer.play_sound(slash_sfx, "Console")
	match dir:
		1:
			anim_player.play("slash_left")
		2:
			anim_player.play("slash_up")
		3:
			anim_player.play("slash_right")
		4: 
			anim_player.play("slash_down")

func _on_animation_player_animation_finished(_anim_name):
	SlashFinished.emit()
	queue_free()

func _on_area_2d_body_entered(body):
	body.take_damage(dir, damage)
