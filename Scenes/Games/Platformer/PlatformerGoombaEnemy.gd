class_name PlatformerGoombaEnemy extends CharacterBody2D

var dir : int = 1
var speed : int = 50
var gravity : int = 200
var stomped : bool = false

@onready var right_floor_check : RayCast2D = $RayCastFloorRight
@onready var left_floor_check : RayCast2D = $RayCastFloorLeft
@onready var right_wall_check : RayCast2D = $RayCastWallRight
@onready var left_wall_check : RayCast2D = $RayCastWallLeft
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("walk")

func _physics_process(_delta: float) -> void:
	if !stomped:
		if dir > 0:
			velocity.x = speed
			if !right_floor_check.is_colliding() or right_wall_check.is_colliding():
				dir = -1
		else:
			velocity.x = -speed
			if !left_floor_check.is_colliding() or left_wall_check.is_colliding():
				dir = 1
	else:
		velocity.x = 0
	
	velocity.y += gravity * _delta
	
	move_and_slide()
	
func getStomped() -> void:
	stomped = true
	anim_player.play("die")

func _on_animation_player_animation_finished(_anim_name):
	if _anim_name == "die":
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	elif _anim_name == "RESET":
		anim_player.play("walk")
		
func respawn() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	stomped = false
	anim_player.play("RESET")
	visible = true
