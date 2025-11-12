extends Node2D

@export var player : ZeldaPlayer
var boss := preload("res://Scenes/Games/Zelda/enemies/ZeldaFinalBoss.tscn")
var timer = 120

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	timer -= 1
	
	if timer <= 0:
		var b = boss.instantiate()
		add_child(b)
		b.player = player
		b.process_mode = Node.PROCESS_MODE_ALWAYS
		process_mode = Node.PROCESS_MODE_DISABLED

func _on_visible_on_screen_notifier_2d_screen_exited():
	get_child(2).queue_free()
