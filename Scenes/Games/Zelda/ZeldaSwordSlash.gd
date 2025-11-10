extends Node2D

signal SlashFinished

var dir : int = 0
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
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
