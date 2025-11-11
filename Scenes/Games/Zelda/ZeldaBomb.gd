class_name ZeldaBomb extends Node2D

var timer = 120
var exploding = false
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var enemy_area : Area2D = $EnemyArea
@onready var wall_area : Area2D = $WallArea
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	timer -= 1
	
	if timer <= 0 and !exploding:
		#bomb explode
		exploding = true
		anim_player.play("explode")
		sprite.visible = false
		for i in randi_range(0, 7):
			get_children()[i].visible = true
		var touching_enemy = enemy_area.get_overlapping_bodies()
		var touching_wall = wall_area.get_overlapping_bodies()
		if touching_enemy:
			for e in touching_enemy:
				e.take_damage(0, 4)
		if touching_wall:
			touching_wall[0].destroy()

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
