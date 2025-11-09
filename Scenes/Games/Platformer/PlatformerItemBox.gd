class_name PlatformerItemBox extends CharacterBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer

var powerup : Resource = preload("res://Scenes/Games/Platformer/PlatformerPowerup.tscn")
var pit_y : int = 0

func _ready() -> void:
	anim_player.play("idle")
	
func respawn() -> void:
	anim_player.play("idle")
	
func checkSpawnItem(_pit_y: int) -> void:
	if anim_player.current_animation == "idle":
		pit_y = _pit_y
		anim_player.play("hit")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hit":
		var instance = powerup.instantiate()
		add_child(instance)
		instance.position = Vector2(0.0, -32.0)
		instance.pit_y = pit_y - position.y
		anim_player.play("empty")
