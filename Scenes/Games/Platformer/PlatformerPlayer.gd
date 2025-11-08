class_name PlatformerPlayer extends CharacterBody2D

@export var speed : int = 150
@export var gravity : int = 500
@export var jump_impulse : int = -375
@export var terminal_velocity : float = 500
@export var top_speed : int = 150
@export var fall_impulse : int = 100

@export var respawn_point : Node2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

signal respawned

var input_axis : float = 0.0
var invuln : bool = false
var invuln_timer : int = 60
var hp : int = 1
var run : bool = false
var pit_y : int = 416

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if anim_player.current_animation != "die":
		input_axis = Input.get_axis("Left", "Right")
		
		invuln_timer -= 1
		if invuln:
			if invuln_timer % 2 == 0:
				sprite.visible = !sprite.visible
			if invuln_timer <= 0:
				invuln = false
				anim_player.play("RESET")
				anim_player.speed_scale = 1
				sprite.visible = true
			
		if abs(input_axis) < 0.1:
			if is_on_floor():
				velocity.x += -velocity.x / 5
				anim_player.play("RESET")
				anim_player.speed_scale = 1
			else:
				velocity.x += -velocity.x / 10
			if abs(velocity.x) < 0.1:
				velocity.x = 0.0
		else:
			if is_on_floor():
				sprite.flip_h = input_axis < 0
				if anim_player.current_animation != "run":
					anim_player.play("run")
				else:
					anim_player.speed_scale = (velocity.x * (1.5 + int(run))) / top_speed
			else:
				anim_player.play("jump")
		
		if Input.is_action_pressed("B"):
			run = true
			top_speed = 200
			speed = 200
		else:
			run = false
			top_speed = 150
			speed = 150
		
		if Input.is_action_just_pressed("A") and is_on_floor():
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
		else:
			velocity.x = top_speed * sign(velocity.x)
				
		if position.x < 8 and input_axis < 0:
			velocity.x = 0
			
		if position.y > pit_y:
			velocity.y = 0
			velocity.x = 0
			anim_player.speed_scale = 1
			anim_player.play("die")
		
		move_and_slide()

func _on_hurtbox_body_entered(_body):
	if !invuln and !_body.stomped:
		hp -= 1
		if hp <= 0:
			velocity.y = 0
			velocity.x = 0
			anim_player.speed_scale = 1
			anim_player.play("die")
		else:
			invuln = true
			invuln_timer = 45

func _on_turtbox_area_entered(_area):
	if !_area.get_parent().stomped and anim_player.current_animation != "die":
		anim_player.play("jump")
		if Input.is_action_pressed("A"):
			velocity.y = (jump_impulse / 1.3)
		else:
			velocity.y = (jump_impulse / 2.0)
		_area.get_parent().getStomped()

func respawn() -> void:
	invuln = false
	sprite.visible = true
	hp = 1
	anim_player.play("RESET")
	anim_player.speed_scale = 1
	velocity = Vector2.ZERO
	position = respawn_point.position
	respawned.emit()

func _on_animation_player_animation_finished(anim_name) -> void:
	if anim_name == "die":
		respawn()
