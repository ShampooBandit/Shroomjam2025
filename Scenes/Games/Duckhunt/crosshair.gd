extends Sprite2D

@export var black_screen: ColorRect

@export var topleft: Node2D
@export var bottomright: Node2D

@export var duck: Duck

@export var game: DuckHuntGame

var on_target = false

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
	
	if Input.is_action_just_pressed("A") and on_target and game.shots > 0 and duck.state == duck.DuckState.FLYING:
		duck.hit()
		game.score += 1


func _physics_process(_delta: float):
	#black_screen.hide()
	if black_screen.modulate.a > 0:
		black_screen.modulate.a -= 0.05
	
	if Input.is_action_just_pressed("A") and game.shots > 0:
	#	black_screen.show()
		black_screen.modulate.a = 0.5
		game.shots -= 1


func _on_crosshair_hitbox_area_entered(area: Area2D) -> void:
	if area is DuckHitbox:
		on_target = true


func _on_crosshair_hitbox_area_exited(area: Area2D) -> void:
	if area is DuckHitbox:
		on_target = false
