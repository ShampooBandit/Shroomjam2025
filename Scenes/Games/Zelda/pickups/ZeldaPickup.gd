extends Node2D

var pickup_sfx := preload("res://SFX/Zelda/heart_pickup.wav")
@onready var sprite := $Sprite2D

func _ready() -> void:
	pass

func _on_area_2d_body_entered(body):
	if body is ZeldaPlayer:
		SoundPlayer.play_sound(pickup_sfx, "Console")
		if body.hp < body.maxhp:
			body.hp += 1
		queue_free()
