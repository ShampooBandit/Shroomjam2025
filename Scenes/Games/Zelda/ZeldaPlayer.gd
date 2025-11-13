class_name ZeldaPlayer extends CharacterBody2D

var bgm_player : AudioStreamPlayer

var overworld_bgm = preload("res://SFX/Zelda/overworld.ogg")
var dungeon_bgm = preload("res://SFX/Zelda/dungeon.ogg")
var boss_bgm = preload("res://SFX/Zelda/boss.ogg")
var title_bgm = preload("res://SFX/Zelda/start_screen.ogg")

var hurt_sfx := preload("res://SFX/Zelda/hurt.wav")
var die_sfx := preload("res://SFX/Zelda/death.wav")
var stair_sfx := preload("res://SFX/Zelda/stairs.wav")
var item_sfx := preload("res://SFX/Zelda/powerup_get.wav")
var morshu_sfx := preload("res://SFX/Zelda/morshu_voice.wav")

var sword_slash : Resource = preload("res://Scenes/Games/Zelda/ZeldaSwordSlash.tscn")
var bomb_resource : Resource = preload("res://Scenes/Games/Zelda/ZeldaBomb.tscn")
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var hurtbox : Area2D = $Hurtbox

@export var camera : ZeldaCamera

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
var in_boss : bool = false
var consider_timer : bool = true
var game_done : bool = false

var touching_enemy : Array
var bomb : Node2D

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Console"
	add_child(bgm_player)

func play_bgm(_bgm: AudioStream) -> void:
	bgm_player.stream = _bgm
	bgm_player.volume_linear = 0.3
	bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()
	
func _physics_process(_delta: float) -> void:
	if !game_done:
		check_screen_transition()
		
		#if Input.is_action_just_pressed("B") and bgm_player.stream != boss_bgm:
			#in_dungeon = true
			#camera.teleport(Vector2(2208.0, -96.0))
			#position = Vector2(2400.0, 200.0)
		
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
	else:
		anim_player.pause()
		timer -= 1
		if timer <= 0:
			timer = 60
			DarkenScreen.emit()

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
			dir = 1
			TARGET_STATE = PlayerState.SCREEN
			return
		elif position.x + 16.0 >= camera.right_border:
			ScreenTransition.emit(3)
			dir = 3
			TARGET_STATE = PlayerState.SCREEN
			return
		
		if position.y - 16.0 <= camera.top_border:
			ScreenTransition.emit(2)
			dir = 2
			TARGET_STATE = PlayerState.SCREEN
			return
		elif position.y + 16.0 >= camera.bottom_border and position.y < 900.0:
			ScreenTransition.emit(4)
			dir = 4
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
			SoundPlayer.play_sound(stair_sfx, "Console")
			anim_player.play("enter")
			consider_timer = false
		PlayerState.EXIT: #exit
			HideScreen.emit()
		PlayerState.SCREEN: #screen
			transition_done = false
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
			anim_player.pause()
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
	elif Input.is_action_just_pressed("B") and bombs:
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
	elif Input.is_action_just_pressed("B") and bombs:
		drop_bomb()
	
	velocity = Vector2(dx, dy) * speed
	
	move_and_slide()
	
func hurt_state_process(_delta: float) -> void:
	timer -= 1
	
	move_and_slide()
	
	print(camera.left_border + 16.0)
	global_position.x = clamp(global_position.x, camera.left_border + 32.0, camera.right_border - 32.0)
	global_position.y = clamp(global_position.y, camera.top_border + 96.0 + 32.0, camera.bottom_border + 96.0 - 32.0)
	
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
			if in_building:
				bgm_player.volume_linear = 0.1
	
func exit_state_process(_delta: float) -> void:
	if consider_timer:
		timer -= 1
		if timer <= 0:
			if anim_player.current_animation != "exit":
				camera.teleport(target_cam_pos)
				position = target_pos
				ShowScreen.emit()
				SoundPlayer.play_sound(stair_sfx, "Console")
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
	if in_dungeon:
		if in_boss:
			camera.teleport(Vector2(2208.0, -96.0))
			position = Vector2(2640.0, 176.0)
			in_boss = false
			stop_bgm()
			play_bgm(dungeon_bgm)
		else:
			camera.teleport(Vector2(2208.0, 544.0))
			position = Vector2(2463.0, 928.0)
			play_bgm(dungeon_bgm)
	else:
		camera.teleport(Vector2(0.0, -96.0))
		position = Vector2(172.0, 128.0)
		play_bgm(overworld_bgm)
	hp = maxhp
	TARGET_STATE = PlayerState.IDLE
	Respawn.emit()

func on_enter(_pos : Vector2, _campos : Vector2, _in_building : bool, _dungeon_entrance : bool) -> void:
	target_cam_pos = _campos
	target_pos = _pos
	if _in_building:
		in_building = true
	if _dungeon_entrance:
		in_dungeon = true
		bgm_player.stop()
		bgm_player.stream = dungeon_bgm
	TARGET_STATE = PlayerState.ENTER
	camera.TransitionStart.emit()
	
func on_exit(_pos : Vector2, _campos : Vector2, _in_building : bool, _dungeon_exit : bool) -> void:
	target_cam_pos = _campos
	target_pos = _pos
	if _dungeon_exit:
		bgm_player.stop()
		bgm_player.stream = overworld_bgm
		in_dungeon = false
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
		if !bgm_player.playing:
			bgm_player.play()
		dir = 2
		return
	elif _anim_name == "exit":
		TARGET_STATE = PlayerState.IDLE
		anim_player.play("RESET")
		camera.TransitionComplete.emit()
		bgm_player.volume_linear = 0.3
		if !bgm_player.playing:
			bgm_player.play()
		dir = 4
		return
		
	if !sword and STATE == PlayerState.ATTACK:
		TARGET_STATE = PlayerState.IDLE

func _on_itembox_area_entered(_item):
	item_holding = _item.get_parent()
	match item_holding.item_id:
		0:
			SoundPlayer.play_sound(item_sfx, "Console")
			sword = true
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)
			item_holding.anim_player.play("item0")
		1:
			SoundPlayer.play_sound(item_sfx, "Console")
			bombs = true
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)
			item_holding.anim_player.play("item1")
		2:
			SoundPlayer.play_sound(item_sfx, "Console")
			item_holding.unlock_door()
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)
		3:
			if item_holding.morshu:
				SoundPlayer.play_sound(morshu_sfx, "Console")
			else:
				SoundPlayer.play_sound(item_sfx, "Console")
			maxhp += 2
			hp = maxhp
			TARGET_STATE = PlayerState.ITEM
			item_holding.position = position - Vector2(0.0, 34.0)

func _on_hurtbox_body_entered(_body):
	if invuln_timer <= 0 and STATE != PlayerState.DIE:
		SoundPlayer.play_sound(hurt_sfx, "Console")
		hp -= _body.damage
		if hp > 0:
			TARGET_STATE = PlayerState.HURT
		else:
			stop_bgm()
			SoundPlayer.play_sound(die_sfx, "Console")
			TARGET_STATE = PlayerState.DIE
			camera.TransitionStart.emit()
		invuln_timer = 60
		timer = 5
