class_name ZeldaGame extends Node2D

@onready var tilemap1 := $Container/TileMapLayer1
@onready var tilemap2 := $Container/TileMapLayer2
@onready var tilemap3 := $Container/TileMapLayer3
@onready var tilemaps : Array = [tilemap1, tilemap2, tilemap3]
@onready var gameViewport := $Container
@onready var gui := $GUI
@onready var player := $Container/ZeldaPlayer

func _ready() -> void:
	pass
	
func hide_game() -> void:
	visible = false
	gui.visible = false
	
func show_game() -> void:
	visible = true
	gui.visible = true

func disable_tilemaps() -> void:
	for t in tilemaps:
		t.collision_enabled = false

func enable_tilemaps() -> void:
	for t in tilemaps:
		t.collision_enabled = true

func restart_game() -> void:
	player.respawn()

func _on_player_darken_screen() -> void:
	gameViewport.modulate = gameViewport.modulate.darkened(0.7)

func _on_player_respawn():
	gameViewport.modulate = Color.WHITE

func _on_player_hide_screen():
	gameViewport.modulate = Color.BLACK

func _on_player_show_screen():
	gameViewport.modulate = Color.WHITE
