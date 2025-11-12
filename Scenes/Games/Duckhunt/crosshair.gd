extends Sprite2D

@export var black_screen: ColorRect

@export var topleft: Node2D
@export var bottomright: Node2D

@export var duck: Duck
@export var clay1: ClayPigeon
@export var clay2: ClayPigeon2

@export var game: DuckHuntGame

var on_target_duck = false
var on_target_clay1 = false
var on_target_clay2 = false

func _process(delta: float):
	var move_vector_h = Input.get_axis("Left", "Right")
	if global_position.x + move_vector_h > bottomright.global_position.x:
		move_vector_h = 0
	if global_position.x + move_vector_h < topleft.global_position.x:
		move_vector_h = 0
	var move_vector_v = Input.get_axis("Up", "Down")
	if global_position.y + move_vector_v > bottomright.global_position.y:
		move_vector_v = 0
	if global_position.y + move_vector_v < topleft.global_position.y:
		move_vector_v = 0
	position += Vector2(move_vector_h, move_vector_v) * delta * 120
	
	if Input.is_action_just_pressed("A") and game.shots > 0:
		if on_target_duck and duck.state == duck.DuckState.FLYING:
			duck.hit()
			game.earn_point()
		if on_target_clay1 and clay1.state == clay1.ClayState.FLYING:
			clay1.hit()
			game.earn_first_point()
		if on_target_clay2 and clay2.state == clay2.ClayState.FLYING:
			clay2.hit()
			game.earn_second_point()


func _physics_process(delta: float):
	#black_screen.hide()
	if black_screen.modulate.a > 0:
		black_screen.modulate.a -= 0.05
	
	if Input.is_action_just_pressed("A") and game.shots > 0:
	#	black_screen.show()
		black_screen.modulate.a = 0.5
		game.shots -= 1


func _on_crosshair_hitbox_area_entered(area: Area2D) -> void:
	if area is DuckHitbox:
		match area.hitbox_type:
			0:
				on_target_duck = true
			1:
				on_target_clay1 = true
			2:
				on_target_clay2 = true


func _on_crosshair_hitbox_area_exited(area: Area2D) -> void:
	if area is DuckHitbox:
		match area.hitbox_type:
			0:
				on_target_duck = false
			1:
				on_target_clay1 = false
			2:
				on_target_clay2 = false
