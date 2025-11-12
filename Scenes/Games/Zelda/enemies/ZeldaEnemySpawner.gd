extends Node2D

var enemy1 : Resource = preload("res://Scenes/Games/Zelda/enemies/ZeldaEnemy1.tscn")
var enemy2 : Resource = preload("res://Scenes/Games/Zelda/enemies/ZeldaEnemy2.tscn")
var enemy3 : Resource = preload("res://Scenes/Games/Zelda/enemies/ZeldaEnemy3.tscn")
var enemy4 : Resource = preload("res://Scenes/Games/Zelda/enemies/ZeldaEnemy4.tscn")

@export var enemy_id : int = 0
@export var camera : ZeldaCamera
@export var enemy_hp : int = 1

var enemy_child : CharacterBody2D = null
var pickup : Node2D = null

func _ready() -> void:
	camera.TransitionComplete.connect(_on_transition_complete)
	camera.TransitionStart.connect(_on_transition_start)

func _on_transition_start() -> void:
	if enemy_child:
		enemy_child.queue_free()
		enemy_child = null
	if pickup:
		pickup.queue_free()
		pickup = null

func _on_transition_complete() -> void:
	if (global_position.y > camera.top_border + 96.0 and 
	global_position.y < camera.bottom_border + 96.0):
		match enemy_id:
			0:
				var enemy = enemy1.instantiate()
				add_child(enemy)
				enemy_child = enemy
			1:
				var enemy = enemy2.instantiate()
				add_child(enemy)
				enemy_child = enemy
				enemy_child.damage = 2
			2:
				var enemy = enemy3.instantiate()
				add_child(enemy)
				enemy_child = enemy
			3:
				var enemy = enemy4.instantiate()
				add_child(enemy)
				enemy_child = enemy
				enemy_child.damage = 2
			4:
				pass
		enemy_child.hp = enemy_hp
		enemy_child.left_border = camera.left_border + 32.0
		enemy_child.right_border = camera.right_border - 32.0
		enemy_child.top_border = camera.top_border + 96.0 + 32.0
		enemy_child.bottom_border = camera.bottom_border + 96.0 - 32.0
