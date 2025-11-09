class_name ZeldaPlayer extends CharacterBody2D

var sword_slash : Resource = preload("res://Scenes/Games/Zelda/ZeldaSwordSlash.tscn")
@onready var anim_player : AnimationPlayer = $AnimationPlayer

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

var STATE : int = PlayerState.IDLE
var TARGET_STATE : int = PlayerState.IDLE

var state_process : StringName

var invuln_timer : int = 0
var timer : int = 0
var dir : int = 4
var dpad_input : int = 0
var speed : int = 100
var hp : int = 10
var maxhp : int = 10

var sword : bool = true
var bombs : bool = false

var transition_done : bool = false
var in_dungeon : bool = true

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	check_screen_transition()
	
	if Input.is_action_just_pressed("B"):
		hp -= 1
		
	if hp <= 0 and STATE != PlayerState.DIE:
		TARGET_STATE = PlayerState.DIE
	
	if TARGET_STATE != -1:
		enter_state()
	
	if invuln_timer > 0:
		invuln_timer -= 1
	
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
	if STATE != PlayerState.SCREEN:
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
		elif position.y + 16.0 >= camera.bottom_border:
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
				2:
					anim_player.play("idle_up")
				3:
					anim_player.play("idle_right")
				4:
					anim_player.play("idle_down")
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
			pass
		PlayerState.EXIT: #exit
			pass
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
			timer = 60
		PlayerState.TELEPORT: #teleport
			pass
		PlayerState.DIE:
			anim_player.play("die")
			timer = 240
	
	STATE = TARGET_STATE
	state_process = STATE_NAMES[STATE]
	TARGET_STATE = -1

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
	
	velocity = Vector2(dx, dy) * speed
	
	move_and_slide()
	
func hurt_state_process(_delta: float) -> void:
	pass

func attack_state_process(_delta: float) -> void:
	poll_input()
	
func enter_state_process(_delta: float) -> void:
	pass
	
func exit_state_process(_delta: float) -> void:
	pass
	
func screen_state_process(_delta: float) -> void:
	if transition_done:
		TARGET_STATE = PlayerState.IDLE
		transition_done = false
		return
	
	move_and_slide()

func item_state_process(_delta: float) -> void:
	pass
	
func teleport_state_process(_delta: float) -> void:
	pass
	
func die_state_process(_delta: float) -> void:
	timer -= 1
	if timer % 30 == 0:
		DarkenScreen.emit()
	if timer <= 0:
		respawn()

func respawn() -> void:
	if in_dungeon:
		camera.teleport(Vector2(1696.0, 0.0))
		position = Vector2(1750.0, 200.0)
	else:
		camera.teleport(Vector2.ZERO)
		position = Vector2(96.0, 96.0)
	hp = maxhp
	TARGET_STATE = PlayerState.IDLE
	Respawn.emit()

func _on_slash_finished():
	TARGET_STATE = PlayerState.IDLE

func _on_camera_transition_complete():
	transition_done = true
