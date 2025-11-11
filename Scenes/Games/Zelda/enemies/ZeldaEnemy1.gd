extends CharacterBody2D

var dir := 0
var timer := 120
var move : bool = false
var damage : int = 1
var speed : int = 50
var hp : int = 1
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

func _ready() -> void:
	anim_player.play("walk")

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
	
func _idle_process(_delta: float) -> void:
	if timer > 0:
		timer -= 1
	else:
		timer = randi_range(60, 180)
		dir = randi_range(1, 4)
		match dir:
			1:
				velocity = Vector2(-speed, 0.0)
			2:
				velocity = Vector2(0.0, -speed)
			3:
				velocity = Vector2(speed, 0.0)
			4:
				velocity = Vector2(0.0, speed)
	
	move_and_slide()
	
	global_position.x = clamp(global_position.x, left_border, right_border)
	global_position.y = clamp(global_position.y, top_border, bottom_border)
	
	if get_last_slide_collision():
		timer = randi_range(60, 180)
		dir = randi_range(1, 4)
		match dir:
			1:
				velocity = Vector2(-speed, 0.0)
			2:
				velocity = Vector2(0.0, -speed)
			3:
				velocity = Vector2(speed, 0.0)
			4:
				velocity = Vector2(0.0, speed)

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

func die():
	#Add item drop as child of parent so it gets cleaned on screen transition
	
	queue_free()
