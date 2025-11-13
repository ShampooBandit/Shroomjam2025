extends Node2D

@export var player : ZeldaPlayer
var boss := preload("res://Scenes/Games/Zelda/enemies/ZeldaFinalBoss.tscn")
var boss_child : ZeldaFinalBoss
var timer = 120
var on_screen : bool = false
var spawned_boss : bool = false

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if on_screen:
		timer -= 1
		
		if timer <= 0 and !spawned_boss:
			boss_child = boss.instantiate()
			boss_child.player = player
			boss_child.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(boss_child)
			spawned_boss = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	on_screen = false
	spawned_boss = false

func _on_visible_on_screen_notifier_2d_screen_entered():
	timer = 120
	on_screen = true
