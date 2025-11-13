class_name ZeldaGame extends Node2D

@onready var tilemap1 := $Container/TileMapLayer1
@onready var tilemap2 := $Container/TileMapLayer2
@onready var tilemap3 := $Container/TileMapLayer3
@onready var tilemaps : Array = [tilemap1, tilemap2, tilemap3]
@onready var gameViewport := $Container
@onready var gui := $GUI
@onready var player := $Container/ZeldaPlayer
@onready var title := $TitleCanvas
@onready var ending := $EndingCanvas

var end_timer = 300
var do_end_timer = false
var on_title = true

signal ZeldaGameBeat

func _ready() -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED
	gui.visible = false
	ending.visible = false
	title.visible = false

func start_game() -> void:
	gui.visible = true
	title.visible = false
	ending.visible = false
	on_title = false
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.play_bgm(player.overworld_bgm)

func hide_game() -> void:
	visible = false
	gui.visible = false
	title.visible = false
	ending.visible = false
	
func show_game() -> void:
	visible = true
	gui.visible = true
	if on_title:
		title.visible = true

func disable_tilemaps() -> void:
	for t in tilemaps:
		t.collision_enabled = false

func enable_tilemaps() -> void:
	for t in tilemaps:
		t.collision_enabled = true

func reset_game() -> void:
	player.respawn()

func _process(_delta: float) -> void:
	if on_title:
		gui.visible = false
		if Input.is_action_just_pressed("Start"):
			start_game()
	else:
		if do_end_timer:
			end_timer -= 1
			
			if end_timer <= 0:
				ZeldaGameBeat.emit()
				ending.show()
				process_mode = Node.PROCESS_MODE_DISABLED

func _beat_game() -> void:
	do_end_timer = true

func connect_to_boss(_boss: ZeldaFinalBoss) -> void:
	_boss.BossDefeated.connect(_beat_game)

func _on_player_darken_screen() -> void:
	gameViewport.modulate = gameViewport.modulate.darkened(0.7)

func _on_player_respawn():
	gameViewport.modulate = Color.WHITE

func _on_player_hide_screen():
	gameViewport.modulate = Color.BLACK

func _on_player_show_screen():
	gameViewport.modulate = Color.WHITE
