class_name ZeldaFinalBoss extends CharacterBody2D

@onready var anim_player := $AnimationPlayer
var proj := preload("res://Scenes/Games/Zelda/enemies/ZeldaBossProjectile.tscn")

var hurt_sfx := preload("res://SFX/Zelda/enemy_hurt.wav")
var cast_sfx := preload("res://SFX/Zelda/boss_attack.wav")

signal BossDefeated

#0 = idle
#1 = teleport
#2 = cast
#3 = die
var STATE : int = 0

var timer : int = 60
var proj_timer : int = 0
var invuln : bool = false
var invuln_timer : int = 0
var hp : int = 15
var player : ZeldaPlayer
var damage : int = 2

func _ready() -> void:
	get_parent().get_parent().get_parent().connect_to_boss(self)
	player.play_bgm(player.boss_bgm)
	player.in_boss = true
	player.Respawn.connect(_on_player_respawn)
	player.final_boss_trap.enable()
	if player.global_position.x < player.camera.left_border + 46:
		player.global_position.x = player.camera.left_border + 46

func _physics_process(_delta: float) -> void:
	match STATE:
		0:
			_idle_process(_delta)
		1:
			_teleport_process(_delta)
		2:
			_cast_process(_delta)
		3:
			_die_process(_delta)

func _idle_process(_delta: float) -> void:
	if invuln:
		invuln_timer -= 1
		if invuln_timer <= 0:
			invuln = false
			anim_player.play("idle")
	
	timer -= 1
	
	if timer <= 0:
		var action = randi() % 100
		if action <= 50:
			STATE = 2
			if invuln:
				anim_player.play("cast_hurt")
			else:
				anim_player.play("cast")
			proj_timer = 45
			timer = 180
		else:
			STATE = 1
	
func _teleport_process(_delta: float) -> void:
	if invuln:
		invuln_timer -= 1
		if invuln_timer <= 0:
			invuln = false
			anim_player.play("idle")
	
	timer -= 1
	
	if timer <= 0:
		global_position.x = randf_range(2800.0, 3153.0)
		global_position.y = randf_range(190.0, 355.0)
		STATE = 0
		timer = randi_range(60, 120)
	
func _cast_process(_delta: float) -> void:
	if invuln:
		invuln_timer -= 1
		if invuln_timer <= 0:
			invuln = false
			anim_player.play("cast")
	
	timer -= 1
	proj_timer -= 1
	if proj_timer <= 0:
		spawn_projectile()
		proj_timer = 90
	
	if timer <= 0:
		STATE = 1
		if invuln:
			anim_player.play("hurt")
		else:
			anim_player.play("idle")
		timer = 60

func _die_process(_delta: float) -> void:
	timer -= 1
	
	if timer <= 0:
		BossDefeated.emit()
		queue_free()

func spawn_projectile() -> void:
	var p = proj.instantiate()
	add_child(p)
	p.global_position = global_position
	p.velocity = global_position.direction_to(player.global_position) * p.speed

func take_damage(_dir, _damage):
	if !invuln:
		if _damage > 1:
			_damage = 2
		invuln = true
		invuln_timer = 30
		hp -= _damage
		if hp <= 0:
			player.stop_bgm()
			STATE = 3
			timer = 90
			anim_player.play("die")
			player.timer = 60
			player.game_done = true
		if STATE == 0 or STATE == 1:
			SoundPlayer.play_sound(hurt_sfx, "Console")
			anim_player.play("hurt")
		elif STATE == 2:
			SoundPlayer.play_sound(hurt_sfx, "Console")
			anim_player.play("cast_hurt")

func _on_player_respawn() -> void:
	get_parent().process_mode = Node.PROCESS_MODE_INHERIT
	queue_free()
