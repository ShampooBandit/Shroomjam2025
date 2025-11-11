extends CharacterBody2D

var dir = 1
var damage = 1
var speed = 100.0

@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	match dir:
		1:
			velocity = Vector2(-speed, 0.0)
			rotation_degrees = 270.0
		2:
			velocity = Vector2(0.0, -speed)
		3:
			velocity = Vector2(speed, 0.0)
			rotation_degrees = 90.0
		4:
			velocity = Vector2(0.0, speed)
			rotation_degrees = 180.0

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
