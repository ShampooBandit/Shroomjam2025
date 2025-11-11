class_name ZeldaPlayer extends CharacterBody2D

var sword_slash : Resource = preload("res://Scenes/Games/Zelda/ZeldaSwordSlash.tscn")
var bomb_resource : Resource = preload("res://Scenes/Games/Zelda/ZeldaBomb.tscn")
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var hurtbox : Area2D = $Hurtbox

@export var camera : Camera2D

var STATE_NAMES : Array = [&"idle_state_process", &"walk_state_process",
&"hurt_state_process",&"attack_state_process",
&"enter_state_process",&"exit_state_process",
&"screen_state_process",&"item_state_process",
&"teleport_state_process", &"die_state_process"]

enum PlayerState { IDLE, WALK, HURT, ATTACK, ENTER, EXIT, SCREEN, ITEM, TELEPORT, DIE }

signal ScreenTransition
signal Respawn
signal DarkenScreen
signal HideScreen
signal ShowScreen

var STATE : int = PlayerState.IDLE
var TARGET_STATE : int = PlayerState.IDLE

var state_process : StringName
var item_holding : Node2D
var target_cam_pos : Vector2
var target_pos : Vector2

var invuln_timer : int = 0
var timer : int = 0
var dir : int = 4
var dpad_input : int = 0
var speed : int = 100
var hp : int = 6
var maxhp : int = 6

var sword : bool = false
var bombs : bool = false
var transition_done : bool = false
var in_dungeon : bool = false
var in_building : bool = false
var consider_timer : bool = true

var touching_enemy : Array
var bomb : Node2D

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	check_screen_transition()
		
	if hp <= 0 and STATE != PlayerState.DIE:
		TARGET_STATE = PlayerState.DIE
	
	if TARGET_STATE != -1:
		enter_state()
	
	if invuln_timer > 0:
		invuln_timer -= 1
		if invuln_timer % 2 == 0:
			sprite.visible = !sprite.visible
	else:
		touching_enemy = hurtbox.get_overlapping_bodies()
		if touching_enemy:
			_on_hurtbox_body_entered(touching_enemy[0])
		sprite.visible = true
			
	call(state_process, _delta)

func poll_input() -> void:
	dpad_input = 0
	
	if Input.is_action_pressed("Left"):
		dpad_input |= 1
	if Input.is_action_pressed("Up"):
		dpad_input |= 2
	if Input.is_action_pressed("Right"):
		dpad_input |= 4
	if Input.is_action_pressed("Down"):
		dpad_input |= 8

func check_screen_transition() -> void:
	if STATE != PlayerState.SCREEN and !in_building:
		if position.x - 16.0 <= camera.left_border:
			ScreenTransition.emit(1)
			TARGET_STATE = PlayerState.SCREEN
			return
		elif position.x + 16.0 >= camera.right_border:
			ScreenTransition.emit(3)
			TARGET_STATE = PlayerState.SCREEN
			return
		
		if position.y - 16.0 <= camera.top_border:
			ScreenTransition.emit(2)
			TARGET_STATE = PlayerState.SCREEN
			return
		elif position.y + 16.0 >= camera.bottom_border and position.y < 900.0:
			ScreenTransition.emit(4)
			TARGET_STATE = PlayerState.SCREEN
			return

func enter_state() -> void:
	match TARGET_STATE:
		PlayerState.IDLE: #idle
			velocity = Vector2.ZERO
			match dir:
				1:
					anim_player.play("idle_left")
				2:
					anim_player.play("idle_up")
				3:
					anim_player.play("idle_right")
				4:
					anim_player.play("idle_down")
		PlayerState.WALK: #walk
			match dir:
				1:
					anim_player.play("walk_left")
				2:
					anim_player.play("walk_up")
				3:
					anim_player.play("walk_right")
				4:
					anim_player.play("walk_down")
		PlayerState.HURT: #hurt
			match dir:
				1:
					anim_player.play("idle_left")
					velocity = Vector2(400.0, 0.0)
				2:
					anim_player.play("idle_up")
					velocity = Vector2(0.0, 400.0)
				3:
					anim_player.play("idle_right")
					velocity = Vector2(-400.0, 0.0)
				4:
					anim_player.play("idle_down")
					velocity = Vector2(0.0, -400.0)
		PlayerState.ATTACK: #attack
			var ss = null
			if sword:
				ss = sword_slash.instantiate()
				ss.position = Vector2.ZERO
				ss.dir = dir
				ss.SlashFinished.connect(_on_slash_finished)
				add_child(ss)
			match dir:
				1:
					anim_player.play("slash_left")
					if ss:
						ss.position = Vector2(-11.0, 0.0)
				2:
					anim_player.play("slash_up")
					if ss:
						ss.position = Vector2(0.0, -11.0)
				3:
					anim_player.play("slash_right")
					if ss:
						ss.position = Vector2(11.0, 0.0)
				4:
					anim_player.play("slash_down")
					if ss:
						ss.position = Vector2(0.0, 14.0)
		PlayerState.ENTER: #enter
			anim_player.play("enter")
			consider_timer = false
		PlayerState.EXIT: #exit
			HideScreen.emit()
		PlayerState.SCREEN: #screen
			match dir:
				1:
					anim_player.play("walk_left")
					velocity = Vector2(speed / -2.0, 0.0)
				2:
					anim_player.play("walk_up")
					velocity = Vector2(0.0, speed / -2.0)
				3:
					anim_player.play("walk_right")
					velocity = Vector2(speed / 2.0, 0.0)
				4:
					anim_player.play("walk_down")
					velocity = Vector2(0.0, speed / 2.0)
		PlayerState.ITEM: #get item
			anim_player.play("get_item")
			timer = 120
		PlayerState.TELEPORT: #teleport
			pass
		PlayerState.DIE:
			anim_player.play("die")
			timer = 240
	
	STATE = TARGET_STATE
	state_process = STATE_NAMES[STATE]
	TARGET_STATE = -1

func drop_bomb() -> void:
	if !bomb:
		bomb = bomb_resource.instantiate()
		add_child(bomb)
		bomb.position = position + Vector2(0.0, 96.0)

func idle_state_process(_delta: float) -> void:
	poll_input()
	
	match dpad_input:
		1, 3:
			anim_player.play("walk_left")
			dir = 1
			TARGET_STATE = PlayerState.WALK
			return
		2, 6:
			anim_player.play("walk_up")
			dir = 2
			TARGET_STATE = PlayerState.WALK
			return
		4, 12:
			anim_player.play("walk_right")
			dir = 3
			TARGET_STATE = PlayerState.WALK
			return
		8, 9:
			anim_player.play("walk_down")
			dir = 4
			TARGET_STATE = PlayerState.WALK
			return
		
	if Input.is_action_just_pressed("A"):
		TARGET_STATE = PlayerState.ATTACK
	elif Input.is_action_just_pressed("B"):
		drop_bomb()
	
func walk_state_process(_delta: float) -> void:
	poll_input()
	
	var dx = Input.get_axis("Left", "Right")
	var dy = Input.get_axis("Up", "Down")
	
	match dpad_input:
		0:
			TARGET_STATE = PlayerState.IDLE
		1:
			anim_player.play("walk_left")
			dir = 1
		2:
			anim_player.play("walk_up")
			dir = 2
		4:
			anim_player.play("walk_right")
			dir = 3
		8:
			anim_player.play("walk_down")
			dir = 4
	
	if Input.is_action_just_pressed("A"):
		TARGET_STATE = PlayerState.ATTACK
		return
	elif Input.is_action_just_pressed("B"):
		drop_bomb()
	
	velocity = Vector2(dx, dy) * speed
	
	move_and_slide()
	
func hurt_state_process(_delta: float) -> void:
	timer -= 1
	
	move_and_slide()
	
	global_position.x = clamp(global_position.x, camera.left_border, camera.right_border)
	global_position.y = clamp(global_position.y, camera.top_border, camera.bottom_border)
	
	if timer <= 0:
		TARGET_STATE = PlayerState.IDLE

func attack_state_process(_delta: float) -> void:
	poll_input()
	
func enter_state_process(_delta: float) -> void:
	if consider_timer:
		timer -= 1
		
		if timer <= 0:
			camera.teleport(target_cam_pos)
			position = target_pos
			ShowScreen.emit()
			TARGET_STATE = PlayerState.IDLE
			anim_player.play("RESET")
			print(in_building)
	
func exit_state_process(_delta: float) -> void:
	if consider_timer:
		timer -= 1
		if timer <= 0:
			camera.teleport(target_cam_pos)
			position = target_pos
			ShowScreen.emit()
			anim_player.play("exit")
			in_building = false
	
func screen_state_process(_delta: float) -> void:
	if transition_done:
		TARGET_STATE = PlayerState.IDLE
		transition_done = false
		return
	
	move_and_slide()

func item_state_process(_delta: float) -> void:
	if timer > 0:
		timer -= 1
	elif timer <= 0 and Input.is_anything_pressed():
		TARGET_STATE = PlayerState.IDLE
		item_holding.queue_free()
	
func teleport_state_process(_delta: float) -> void:
	pass
	
func die_state_process(_delta: float) -> void:
	timer -= 1
	if timer % 30 == 0:
		DarkenScreen.emit()
	if timer <= 0:
		respawn()

func respawn() -> void:
	if in_building:
		camera.teleport(Vector2(1696.0, -96.0))
		position = Vector2(1750.0, 200.0)
	else:
		camera.teleport(Vector2(0.0, -96.0))
		position = Vector2(172.0, 128.0)
	hp = maxhp
	TARGET_STATE = PlayerState.IDLE
	Respawn.emit()

func on_enter(_pos : Vector2, _campos : Vector2, _in_building : bool) -> void:
	target_cam_pos = _campos
	target_pos = _pos
	in_building = _in_building
	TARGET_STATE = PlayerState.ENTER
	
func on_exit(_pos : Vector2, _campos : Vector2, _in_building : bool) -> void:
	target_cam_pos = _campos
	target_pos = _pos
	TARGET_STATE = PlayerState.EXIT
	timer = 30

func _on_slash_finished():
	TARGET_STATE = PlayerState.IDLE

func _on_camera_transition_complete():
	transition_done = true

func _on_animation_player_animation_finished(_anim_name):
	if _anim_name == "enter":
		HideScreen.emit()
		timer = 30
		consider_timer = true
		dir = 2
		return
	elif _anim_name == "exit":
		TARGET_STATE = PlayerState.IDLE
		anim_player.play("RESET")
		dir = 4
		return
		
	if !sword and STATE == PlayerState.ATTACK:
		TARGET_STATE = PlayerState.IDLE

func _on_itembox_area_entered(_item):
	item_holding = _item.get_parent()
	match item_holding.item_id:
		0:
			sword = true
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)
			item_holding.anim_player.play("item0")
		1:
			bombs = true
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)
			item_holding.anim_player.play("item1")
		2:
			item_holding.unlock_door()
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)
		3:
			maxhp += 2
			hp = maxhp
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)

func _on_hurtbox_body_entered(_body):
	if invuln_timer <= 0 and STATE != PlayerState.DIE:
		hp -= _body.damage
		if hp > 0:
			TARGET_STATE = PlayerState.HURT
		else:
			TARGET_STATE = PlayerState.DIE
		invuln_timer = 60
		timer = 5
