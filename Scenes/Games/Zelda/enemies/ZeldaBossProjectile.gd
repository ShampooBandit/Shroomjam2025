extends CharacterBody2D

@onready var anim_player := $AnimationPlayer

var damage : int = 1
var speed : float = 150.0
var direction : Vector2

func _ready() -> void:
	anim_player.play("fly")

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
