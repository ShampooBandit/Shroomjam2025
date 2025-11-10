class_name PlatformerFireball extends CharacterBody2D

func _ready() -> void:
	velocity.x = -100

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
