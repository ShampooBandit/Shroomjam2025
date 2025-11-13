class_name PlatformerGame extends Node2D

var mountain_bgm := preload("res://SFX/Mario/mountain.mp3")
var city_bgm := preload("res://SFX/Mario/City.mp3")
var castle_bgm := preload("res://SFX/Mario/Castle.mp3")
var bgm_player : AudioStreamPlayer

@onready var camera : Camera2D = $Player/Camera2D
@onready var respawn : Node2D = $Respawn
@onready var player : CharacterBody2D = $Player
@onready var level1enemies : Node2D = $Level1Enemies
@onready var level2enemies : Node2D = $Level2Enemies
@onready var level3enemies : Node2D = $Level3Enemies
@onready var level4enemies : Node2D = $Level4Enemies

@onready var title : TextureRect = $TitleScreen
@onready var ending : TextureRect = $EndScreen
@onready var tilemap : TileMapLayer = $TileMapLayer

var level = 0

signal beatGame

func _ready() -> void:
	player.respawned.connect(_on_player_respawn)
	player.grabbedPole.connect(stop_bgm)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = mountain_bgm
	bgm_player.bus = "Console"
	bgm_player.volume_linear = 0.7
	add_child(bgm_player)

func _physics_process(_delta: float) -> void:
	if level == 0 and Input.is_action_just_pressed("Start"):
		title.visible = false
		player.process_mode = Node.PROCESS_MODE_INHERIT
		goToNextLevel()

func stop_bgm() -> void:
	bgm_player.stop()

func disable_tilemaps() -> void:
	tilemap.collision_enabled = false

func enable_tilemaps() -> void:
	tilemap.collision_enabled = true
	
func hide_game() -> void:
	visible = false
	#gui.visible = false
	
func show_game() -> void:
	visible = true
	#gui.visible = true
	
func goToNextLevel() -> void:
	match level:
		0: #Starting game
			bgm_player.play()
		1: #Going to level 2
			camera.limit_top = 448
			camera.limit_bottom = 864
			respawn.position = Vector2(126.0, 768.0)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom - 8
			player.respawn()
			bgm_player.stream = city_bgm
			bgm_player.play()
		2: #Going to level 3
			camera.limit_top = 896
			camera.limit_bottom = 1312
			respawn.position = Vector2(126.0, 1216.0)
			player.position = respawn.position
			player.pit_y = camera.limit_bottom - 8
			player.respawn()
			bgm_player.stream = castle_bgm
			bgm_player.volume_linear = 0.5
			bgm_player.play()
		3: #Going to level 4
			finishGame()
		4:
			finishGame()
	
	level += 1
	
func finishGame() -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED
	ending.global_position.x = camera.global_position.x - 256.0
	ending.visible = true
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

func reset_game() -> void:
	player.respawn()
