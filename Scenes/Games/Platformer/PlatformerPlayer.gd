class_name PlatformerPlayer extends CharacterBody2D

@export var speed : int = 150
@export var gravity : int = 500
@export var jump_impulse : int = -375
@export var terminal_velocity : float = 500
@export var top_speed : int = 150
@export var fall_impulse : int = 100

@export var respawn_point : Node2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer

var input_axis : float = 0.0
var invuln : bool = false
var invuln_timer : int = 60
var hp : int = 1

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	input_axis = Input.get_axis("Left", "Right")
	
	invuln_timer -= 1
	if invuln and invuln_timer <= 0:
		invuln = false
		anim_player.play("RESET")
	
	if Input.is_action_pressed("A") and is_on_floor():
		velocity.y += jump_impulse
		anim_player.play("jump")
		
	if Input.is_action_just_released("A") and velocity.y < -fall_impulse:
		velocity.y += fall_impulse
	
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, terminal_velocity)
	
	if abs(velocity.x) < top_speed:
		if is_on_floor():
			velocity.x += (Input.get_axis("Left", "Right") * speed) * delta
		else:
			velocity.x += ((Input.get_axis("Left", "Right") * speed) * 2) * delta
		
	if abs(input_axis) < 0.1:
		if is_on_floor():
			velocity.x += -velocity.x / 5
		else:
			velocity.x += -velocity.x / 10
		if abs(velocity.x) < 0.1:
			velocity.x = 0.0
			
	if position.x < 8 and input_axis < 0:
		velocity.x = 0
		
	if position.y > 512:
		respawn()
	
	move_and_slide()

func _on_hurtbox_body_entered(_body):
	if !invuln and !_body.stomped:
		hp -= 1
		invuln = true
		invuln_timer = 30
		anim_player.play("invuln")


func _on_turtbox_area_entered(_area):
	if !_area.get_parent().stomped:
		anim_player.play("jump")
		velocity.y = (jump_impulse / 2.0)
		_area.get_parent().getStomped()

func respawn() -> void:
	invuln = false
	hp = 1
	anim_player.play("RESET")
	velocity = Vector2.ZERO
	position = respawn_point.position
