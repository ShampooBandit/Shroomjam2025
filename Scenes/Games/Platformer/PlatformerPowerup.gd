class_name PlatformerPowerup extends CharacterBody2D

@onready var right_wall_check : RayCast2D = $CheckWallRight
@onready var left_wall_check : RayCast2D = $CheckWallRight

var pit_y : int
var speed : int = 50
var gravity : int = 500

func _ready() -> void:
	velocity.x = speed

func _physics_process(_delta):
	velocity.y += gravity * _delta
	
	if right_wall_check.is_colliding() or left_wall_check.is_colliding():
		velocity.x *= -1
	
	move_and_slide()
	
	if position.y > pit_y:
		queue_free()
