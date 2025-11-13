class_name ZeldaBomb extends Node2D

var lay_sfx := preload("res://SFX/Zelda/bomb_lay.wav")
var explode_sfx := preload("res://SFX/Zelda/bomb_explode.wav")

var timer = 60
var exploding = false
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var enemy_area : Area2D = $EnemyArea
@onready var wall_area : Area2D = $WallArea
@onready var sprite : Sprite2D = $Sprite2D

@onready var explosion1 := $Explosion1
@onready var explosion2 := $Explosion2
@onready var explosion3 := $Explosion3
@onready var explosion4 := $Explosion4
@onready var explosion5 := $Explosion5
@onready var explosion6 := $Explosion6
@onready var explosion7 := $Explosion7

func _ready() -> void:
	SoundPlayer.play_sound(lay_sfx, "Console")

func _physics_process(_delta: float) -> void:
	timer -= 1
	
	if timer <= 0 and !exploding:
		#bomb explode
		SoundPlayer.play_sound(explode_sfx, "Console")
		exploding = true
		sprite.visible = false
		explosion1.visible = true
		explosion2.visible = true
		explosion3.visible = true
		explosion4.visible = true
		explosion5.visible = true
		explosion6.visible = true
		explosion7.visible = true
		anim_player.play("explode")
		var touching_enemy = enemy_area.get_overlapping_bodies()
		var touching_wall = wall_area.get_overlapping_bodies()
		if touching_enemy:
			for e in touching_enemy:
				e.take_damage(0, 4)
		if touching_wall:
			for w in touching_wall:
				if w is ZeldaCrumbleWall:
					touching_wall[0].destroy()

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
