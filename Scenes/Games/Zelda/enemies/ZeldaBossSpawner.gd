extends Node2D

@export var player : ZeldaPlayer
var boss := preload("res://Scenes/Games/Zelda/enemies/ZeldaFinalBoss.tscn")
var boss_child : ZeldaFinalBoss
var timer = 120
var on_screen : bool = false
var spawned_boss : bool = false

func _ready() -> void:
	player.Respawn.connect(_on_player_respawn)

func _on_player_respawn() -> void:
	on_screen = false
	timer = 120
	boss_child = null
	spawned_boss = false

func _physics_process(_delta: float) -> void:
	if on_screen:
		timer -= 1
		
		if timer <= 0 and !boss_child and !spawned_boss:
			boss_child = boss.instantiate()
			boss_child.player = player
			boss_child.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(boss_child)
			spawned_boss = true

func _on_visible_on_screen_notifier_2d_screen_entered():
	timer = 120
	on_screen = true
