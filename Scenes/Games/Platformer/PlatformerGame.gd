class_name PlatformerGame extends Node2D

@onready var camera : Camera2D = $Player/Camera2D
@onready var respawn : Node2D = $Respawn
@onready var player : CharacterBody2D = $Player
@onready var level1enemies : Node2D = $Level1Enemies
@onready var level2enemies : Node2D = $Level2Enemies
@onready var level3enemies : Node2D = $Level3Enemies
@onready var level4enemies : Node2D = $Level4Enemies

@onready var tilemap : TileMapLayer = $TileMapLayer

var level = 1

signal beatGame

func _ready() -> void:
	player.respawned.connect(_on_player_respawn)
	
func disable_tilemaps() -> void:
	tilemap.collision_enabled = false

func enable_tilemaps() -> void:
	tilemap.collision_enabled = true
	
func goToNextLevel() -> void:
	match level:
		1:
			camera.limit_top = 448
			camera.limit_bottom = 864
			respawn.position = Vector2(4800, 480)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom - 8
			player.respawn()
		2:
			camera.limit_top = 896
			camera.limit_bottom = 1312
			respawn.position = Vector2(4800, 1232)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom - 8
			player.respawn()
		3:
			camera.limit_top = 1344
			camera.limit_bottom = 1760
			respawn.position = Vector2(4800, 1600)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom - 8
			player.respawn()
		4:
			finishGame()
	
	level += 1
	
func finishGame() -> void:
	beatGame.emit()
		
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

func _on_player_next_level():
	goToNextLevel()
