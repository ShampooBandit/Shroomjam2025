extends Node2D

var enemy1 : Resource = preload("res://Scenes/Games/Zelda/enemies/ZeldaEnemy1.tscn")

@export var enemy_id : int = 0
@export var camera : ZeldaCamera

func _ready() -> void:
	camera.TransitionComplete.connect(_on_transition_complete)
	camera.TransitionStart.connect(_on_transition_start)

func _on_transition_start() -> void:
	get_child(0).queue_free()

func _on_transition_complete() -> void:
	match enemy_id:
		0:
			var enemy = enemy1.instantiate()
			add_child(enemy)
