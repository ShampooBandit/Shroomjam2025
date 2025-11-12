class_name Hands extends Node2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "nes":
		anim_player.play("idle_nes")
	elif anim_name == "remote":
		anim_player.play("idle_remote")
	elif anim_name == "zapper":
		anim_player.play("idle_zapper")
