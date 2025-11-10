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
@onready var hurtbox : CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var wallbox : CollisionShape2D = $Wallbox
@onready var headbox : CollisionShape2D = $Headbox/CollisionShape2D

signal respawned
signal nextLevel

var input_axis : float = 0.0
var invuln : bool = false
var invuln_timer : int = 60
var hp : int = 1
var run : bool = false
@export var pit_y : int = 406
var beat_level : bool = false
var flag_bottom : float = 0.0
var getting_powerup : bool = false

func _ready() -> void:
	#getPowerup()
	pass
	
func _physics_process(_delta: float) -> void:
	if beat_level:
		levelEnd()
	elif getting_powerup:
		pass
	else:
		if hp == 2:
			_big_physics_process(_delta)
		else:
			_small_physics_process(_delta)

func levelEnd() -> void:
	if position.y < flag_bottom:
		position.y += 2.0
		if position.y >= flag_bottom:
			invuln_timer = 60
	else:
		invuln_timer -= 1
		if invuln_timer <= 0:
			nextLevel.emit()
	return

func getPowerup() -> void:
	if hp == 1:
		hp = 2
		speed = 150
		gravity = 500
		jump_impulse = -375
		terminal_velocity = 500
		top_speed = 150
		fall_impulse = 100
		hurtbox.shape.size = Vector2(24.0, 50.0)
		hurtbox.position = Vector2(0.0, 4.0)
		wallbox.shape.size = Vector2(24.0, 50.0)
		wallbox.position = Vector2(0.0, 4.0)
		headbox.position = Vector2(0.0, -24.0)
	getting_powerup = false
		
func losePowerup() -> void:
	speed = 150
	gravity = 500
	jump_impulse = -375
	terminal_velocity = 500
	top_speed = 150
	fall_impulse = 100
	hurtbox.shape.size = Vector2(24.0, 24.0)
	hurtbox.position = Vector2(0.0, 16.0)
	wallbox.shape.size = Vector2(24.0, 28.0)
	wallbox.position = Vector2(0.0, 18.0)
	headbox.position = Vector2(0.0, 2.0)
	anim_player.play("RESET")

func _small_physics_process(delta: float) -> void:
	if anim_player.current_animation != "die" and anim_player.current_animation != "big_hurt":
		input_axis = Input.get_axis("Left", "Right")
		
		if invuln:
			invuln_timer -= 1
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

func _big_physics_process(delta: float) -> void:
	if anim_player.current_animation != "big_hurt" and anim_player.current_animation != "die":
		input_axis = Input.get_axis("Left", "Right")
		
		if invuln:
			invuln_timer -= 1
			if invuln_timer % 2 == 0:
				sprite.visible = !sprite.visible
			if invuln_timer <= 0:
				invuln = false
				anim_player.play("BIG_RESET")
				anim_player.speed_scale = 1
				sprite.visible = true
			
		if abs(input_axis) < 0.1:
			if is_on_floor():
				velocity.x += -velocity.x / 5
				anim_player.play("BIG_RESET")
				anim_player.speed_scale = 1
			else:
				velocity.x += -velocity.x / 10
			if abs(velocity.x) < 0.1:
				velocity.x = 0.0
		else:
			if is_on_floor():
				sprite.flip_h = input_axis < 0
				if anim_player.current_animation != "big_run":
					anim_player.play("big_run")
				else:
					anim_player.speed_scale = (abs(velocity.x) * (1.5 + int(run))) / top_speed
			else:
				anim_player.play("big_jump")
		
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
			anim_player.play("big_jump")
			
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
	if _body is PlatformerPowerup:
		velocity = Vector2.ZERO
		anim_player.speed_scale = 1
		anim_player.play("powerup")
		getting_powerup = true
		_body.queue_free()
	else:
		if !invuln and !_body.stomped:
			hp -= 1
			if hp <= 0:
				velocity.y = 0
				velocity.x = 0
				anim_player.speed_scale = 1
				anim_player.play("die")
			elif hp == 1:
				invuln = true
				invuln_timer = 45
				anim_player.speed_scale = 1
				anim_player.play("big_hurt")

func _on_turtbox_area_entered(_area):
	if !_area.get_parent().stomped and anim_player.current_animation != "die":
		if hp == 2:
			anim_player.play("big_jump")
		else:
			anim_player.play("jump")
		if Input.is_action_pressed("A"):
			velocity.y = (jump_impulse / 1.3)
		else:
			velocity.y = (jump_impulse / 2.0)
		_area.get_parent().getStomped()

func respawn() -> void:
	sprite.position.y = 0.0
	if beat_level:
		if hp == 2:
			anim_player.play("BIG_RESET")
		else:
			anim_player.play("RESET")
		beat_level = false
		invuln = false
		invuln_timer = 0
		sprite.visible = true
		anim_player.speed_scale = 1
		velocity = Vector2.ZERO
		position = respawn_point.position
		respawned.emit()
	else:
		invuln = false
		invuln_timer = 0
		sprite.visible = true
		hp = 1
		anim_player.play("RESET")
		anim_player.speed_scale = 1
		velocity = Vector2.ZERO
		position = respawn_point.position
		respawned.emit()
		losePowerup()

func _on_animation_player_animation_finished(anim_name) -> void:
	if anim_name == "die":
		respawn()
	elif anim_name == "big_hurt":
		losePowerup()
	elif anim_name == "powerup":
		getPowerup()

func _on_hurtbox_area_entered(_area) -> void:
	beat_level = true
	position.x = _area.position.x - 8
	flag_bottom = _area.position.y + (_area.get_child(0).shape.size.y / 2) - 32.0
	anim_player.speed_scale = 1
	if hp == 2:
		anim_player.play("big_flag")
	else:
		anim_player.play("flag")

func _on_headbox_body_entered(_body: Node2D):
	_body.checkSpawnItem(pit_y)
