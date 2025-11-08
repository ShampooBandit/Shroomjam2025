class_name PlatformerGame extends Node2D

@onready var camera : Camera2D = $Player/Camera2D
@onready var respawn : Node2D = $Respawn
@onready var player : CharacterBody2D = $Player
@onready var level1enemies : Node2D = $Level1Enemies
@onready var level2enemies : Node2D = $Level2Enemies
@onready var level3enemies : Node2D = $Level3Enemies
@onready var level4enemies : Node2D = $Level4Enemies

var level = 1

func _ready() -> void:
	player.respawned.connect(_on_player_respawn)
	
func goToNextLevel() -> void:
	match level:
		1:
			camera.limit_top = 448
			camera.limit_bottom = 864
			respawn.position = Vector2(48, 480)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom
		2:
			camera.limit_top = 448
			camera.limit_bottom = 864
			respawn.position = Vector2(48, 480)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom
		3:
			camera.limit_top = 448
			camera.limit_bottom = 864
			respawn.position = Vector2(48, 480)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom
		4:
			camera.limit_top = 448
			camera.limit_bottom = 864
			respawn.position = Vector2(48, 480)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom
	
	level += 1

func _on_end_of_level_1_body_entered(_body) -> void:
	if _body == player:
		goToNextLevel()

func _on_end_of_level_2_body_entered(_body) -> void:
	if _body == player:
		goToNextLevel()
		
func _on_player_respawn() -> void:
	match level:
		1:
			for child in level1enemies.get_children():
				child.respawn()
		2:
			for child in level2enemies.get_children():
				child.respawn()
		3:
			for child in level3enemies.get_children():
				child.respawn()
		4:
			for child in level4enemies.get_children():
				child.respawn()
