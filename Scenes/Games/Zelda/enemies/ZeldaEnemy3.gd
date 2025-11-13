extends CharacterBody2D

@onready var arrow := preload("res://Scenes/Games/Zelda/enemies/ZeldaEnemyArrow.tscn")
@onready var pickup := preload("res://Scenes/Games/Zelda/pickups/ZeldaPickup.tscn")

var hurt_sfx := preload("res://SFX/Zelda/enemy_hurt.wav")
var die_sfx := preload("res://SFX/Zelda/enemy_die.wav")

var dir := 3
var timer := 120
var move : bool = false
var damage : int = 1
var speed : int = 50
var hp : int = 3
var color : Color = Color.WHITE
var invuln_timer : int = 0

var left_border : float
var right_border : float
var top_border : float
var bottom_border : float

#0 - moving around, 1 - hurt
var STATE : int = 0

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var up_wall : RayCast2D = $UpWallCast
@onready var up_wall2 : RayCast2D = $UpWallCast2
@onready var down_wall : RayCast2D = $DownWallCast
@onready var down_wall2 : RayCast2D = $DownWallCast2
@onready var left_wall : RayCast2D = $LeftWallCast
@onready var left_wall2 : RayCast2D = $LeftWallCast2
@onready var right_wall : RayCast2D = $RightWallCast
@onready var right_wall2 : RayCast2D = $RightWallCast2

func _ready() -> void:
	anim_player.play("walk_down")

func _physics_process(_delta: float) -> void:
	if invuln_timer > 0:
		invuln_timer -= 1
		if invuln_timer % 2 == 0:
			sprite.visible = !sprite.visible
	else:
		sprite.visible = true
	
	match STATE:
		0:
			_idle_process(_delta)
		1:
			_hurt_process(_delta)
		2:
			_attack_process(_delta)
	
func check_wall_direction() -> int:
	var possible_dir = []
	var chosen_dir = 0
	if !left_wall.is_colliding() and !left_wall2.is_colliding():
		possible_dir.append(1)
		
	if !up_wall.is_colliding() and !up_wall2.is_colliding():
		possible_dir.append(2)
		
	if !right_wall.is_colliding() and !right_wall2.is_colliding():
		possible_dir.append(3)
		
	if !down_wall.is_colliding() and !down_wall2.is_colliding():
		possible_dir.append(4)
	
	chosen_dir = randi_range(0, len(possible_dir)-1)
	
	if len(possible_dir > 0):
		return possible_dir[chosen_dir]
	else:
		return 0
	
func _attack_process(_delta: float) -> void:
	if timer > 0:
		timer -= 1
	else:
		var a = arrow.instantiate()
		a.dir = dir
		a.global_position = global_position
		add_child(a)
	
		STATE = 0
	
func _idle_process(_delta: float) -> void:
	if timer > 0:
		timer -= 1
	else:
		if randi() % 100 < 50:
			timer = randi_range(60, 120)
			match dir:
				1:
					anim_player.play("walk_left")
				2:
					anim_player.play("walk_up")
				3:
					anim_player.play("walk_right")
				4:
					anim_player.play("walk_down")
			STATE = 2
			return
		timer = randi_range(60, 180)
		dir = check_wall_direction()
		match dir:
			1:
				velocity = Vector2(-speed, 0.0)
				anim_player.play("walk_left")
			2:
				velocity = Vector2(0.0, -speed)
				anim_player.play("walk_up")
			3:
				velocity = Vector2(speed, 0.0)
				anim_player.play("walk_right")
			4:
				velocity = Vector2(0.0, speed)
				anim_player.play("walk_down")
	
	move_and_slide()
	
	global_position.x = clamp(global_position.x, left_border, right_border)
	global_position.y = clamp(global_position.y, top_border, bottom_border)
	
	#if get_last_slide_collision():
		#timer = randi_range(60, 180)
		#dir = check_wall_direction()
		#match dir:
			#1:
				#velocity = Vector2(-speed, 0.0)
				#anim_player.play("walk_left")
			#2:
				#velocity = Vector2(0.0, -speed)
				#anim_player.play("walk_up")
			#3:
				#velocity = Vector2(speed, 0.0)
				#anim_player.play("walk_right")
			#4:
				#velocity = Vector2(0.0, speed)
				#anim_player.play("walk_down")

func _hurt_process(_delta: float) -> void:
	timer -= 1
	
	move_and_slide()
	
	global_position.x = clamp(global_position.x, left_border, right_border)
	global_position.y = clamp(global_position.y, top_border, bottom_border)
	
	if get_last_slide_collision() or timer <= 0:
		STATE = 0

func take_damage(_dir : int, _dmg : int):
	hp -= _dmg
	if hp <= 0:
		die()
		
	if invuln_timer <= 0:
		match _dir:
			1:
				velocity = Vector2(-400.0, 0.0)
			2:
				velocity = Vector2(0.0, -400.0)
			3:
				velocity = Vector2(400.0, 0.0)
			4:
				velocity = Vector2(0.0, 400.0)
		STATE = 1
		invuln_timer = 30
		timer = 5
		SoundPlayer.play_sound(hurt_sfx, "Console")

func die():
	#Add item drop as child of parent so it gets cleaned on screen transition
	var chance = randi() % 100
	SoundPlayer.play_sound(die_sfx, "Console")
	if chance < 25:
		var p = pickup.instantiate()
		get_parent().add_child(p)
		get_parent().pickup = p
		p.position = position
	queue_free()
