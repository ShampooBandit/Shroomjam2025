extends AnimatedSprite2D
class_name ClayPigeon2

enum ClayState {NEUTRAL, FLYING, HIT, TOOLATE, INTRO}

var hard = false

var state = ClayState.NEUTRAL
# 0 - neutral
# 1 - flying
# 2 - hit
# 3 - too late

var flying_left = false

@export var topleft: Node2D
@export var bottomright: Node2D

@export var white_square: ColorRect

@export var fly_away_text: Label

@export var duck_spawner: Node2D

@export var game: DuckHuntGame

@export var other_pigeon: ClayPigeon

@export var duck_hitbox: DuckHitbox

var timer = 0

var base_mult = 0

var v_velocity = 0

var base_speed = 5 # The speed multiplier of the duck when flying.
var hori_speed = 0.5
var time_to_hit = 5 # At minimum, how long the duck waits to get hit in seconds

func _ready():
	random_trajectory()
	

func _physics_process(_delta: float):
	if hard == true:
		base_speed = 8
	else:
		base_speed = 5
	if game.gamemode != game.Gamemode.CLAY:
		hide()
		duck_hitbox.monitoring = false
		duck_hitbox.monitorable = false
		white_square.hide()
		return
	else:
		duck_hitbox.monitoring = true
		duck_hitbox.monitorable = true
		white_square.show()
		show()
	if game.gamemode != game.Gamemode.CLAY:
		state = ClayState.NEUTRAL
		hide()
		duck_hitbox.monitoring = false
		duck_hitbox.monitorable = false
	else:
		show()
		duck_hitbox.monitoring = true
		duck_hitbox.monitorable = true
	timer -= 1
	v_velocity *= 0.95
	match state:
		ClayState.INTRO:
			white_square.hide()
			if timer <= 0:
				respawn_pigeon()
		ClayState.FLYING:
			# Move the character
			if flying_left:
				position += Vector2(-hori_speed-base_mult, (-base_speed-base_mult) * v_velocity)
			else:
				position += Vector2(hori_speed+base_mult, (-base_speed-base_mult) * v_velocity)
			# Display white square in the right position
			white_square.show()
			white_square.global_position = global_position + Vector2(-24, -20)
			if timer <= 0:
				state = ClayState.TOOLATE
				white_square.hide()
				game.clay1 += 1
		ClayState.HIT:
			hide()
			white_square.hide()
		ClayState.TOOLATE:
			hide()
			white_square.hide()
			if timer <= 0:
				pass

func random_trajectory():
	if randi() % 2:
		flying_left = true
		flip_h = true
	else:
		flying_left = false
		flip_h = false

func hit():
	if state != ClayState.FLYING:
		return
	state = ClayState.HIT
	timer = 30
	game.pointscore += 1000

func respawn_pigeon():
	global_position = duck_spawner.global_position + Vector2(randi_range(-50, 50), 0)
	show()
	random_trajectory()
	state = ClayState.FLYING
	timer = 120
	v_velocity = 1
	frame = 0
	play()
