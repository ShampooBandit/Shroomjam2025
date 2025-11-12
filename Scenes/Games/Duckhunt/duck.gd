extends AnimatedSprite2D
class_name Duck

enum DuckState {NEUTRAL, FLYING, HIT, FALLING, FLY_AWAY, DOG_CATCH, DOG_GIGGLE}

var state = DuckState.NEUTRAL
# 0 - neutral
# 1 - flying
# 2 - hit
# 3 - falling
# 4 - fly away
# 5 - dog catch
# 6 - dog giggle

var color = 0
# 0 - green - 500 points
# 1 - red - 1500 points
# 2 - blue - 1000 points

var flying_left = false
var flying_down = false

@export var topleft: Node2D
@export var bottomright: Node2D

@export var white_square: ColorRect

@export var fly_away_text: Label

@export var duck_spawner: Node2D

@export var game: DuckHuntGame

@export var dog: DuckHuntDog

@export var duck_hitbox: DuckHitbox

var timer = 0

var random_x_offset = 0
var random_y_offset = 0

var base_mult = 0

var base_speed = 1.2 # The speed multiplier of the duck when flying.
var time_to_hit = 5 # At minimum, how long the duck waits to get hit in seconds

func _ready():
	play()
	select_color()
	random_trajectory()
	

<<<<<<< Updated upstream
func _physics_process(delta: float):
=======
func _physics_process(_delta: float):
	if game.gamemode != game.Gamemode.NORMAL:
		state = DuckState.NEUTRAL
		hide()
		duck_hitbox.monitoring = false
		duck_hitbox.monitorable = false
		white_square.hide()
	else:
		show()
		duck_hitbox.monitoring = true
		duck_hitbox.monitorable = true
		white_square.show()
>>>>>>> Stashed changes
	timer -= 1
	match state:
		DuckState.NEUTRAL: # cooldown
			white_square.hide()
			if timer <= 0 and game.gamemode == game.Gamemode.NORMAL:
				state = DuckState.FLYING
				timer = time_to_hit * 60
				reroll_random_offsets()
				match color:
					0:
						animation = "green_flying"
					1:
						animation = "red_flying"
					2:
						animation = "blue_flying"
		DuckState.FLYING:
			game.flyingcurrently = true
			# Move the character
			if flying_left:
				if flying_down:
					position += Vector2(-base_speed+random_x_offset-base_mult, base_speed+random_y_offset+base_mult)
				else:
					position += Vector2(-base_speed+random_x_offset-base_mult, -base_speed+random_y_offset-base_mult)
			else:
				if flying_down:
					position += Vector2(base_speed+random_x_offset+base_mult, base_speed+random_y_offset+base_mult)
				else:
					position += Vector2(base_speed+random_x_offset+base_mult, -base_speed+random_y_offset-base_mult)
			# Turn on edges
			if timer > 0 and global_position.y < topleft.global_position.y + 40:
				flying_down = true
				reroll_random_offsets()
			if global_position.y > bottomright.global_position.y - 190:
				flying_down = false
				reroll_random_offsets()
			if global_position.x < topleft.global_position.x + 30:
				flying_left = false
				flip_h = false
				reroll_random_offsets()
			if global_position.x > bottomright.global_position.x - 30:
				flying_left = true
				flip_h = true
				reroll_random_offsets()
			# Display white square in the right position
			white_square.show()
			white_square.global_position = global_position + Vector2(-32, -32)
			if timer <= 0 and global_position.y < topleft.global_position.y + 40:
				timer = 60
				state = DuckState.FLY_AWAY
				fly_away_text.show()
				white_square.hide()
				dog.miss()
				game.duck += 1
		DuckState.HIT:
			game.flyingcurrently = false
			if timer <= 0:
				state = DuckState.FALLING
				match color:
					0:
						animation = "green_falling"
					1:
						animation = "red_falling"
					2:
						animation = "blue_falling"
		DuckState.FALLING:
			white_square.hide()
			position += Vector2(0, 1.5)
			if global_position.y >= duck_spawner.global_position.y:
				game.shots = 3
				timer = 90
				dog.hit()
				respawn_duck()
		DuckState.FLY_AWAY:
			game.flyingcurrently = false
			if flying_left:
				position += Vector2(-1, -1)
			else:
				position += Vector2(1, -1)
			if timer <= 0:
				respawn_duck()
				fly_away_text.hide()
				game.shots = 3
				timer = 60
		DuckState.DOG_CATCH:
			pass
		DuckState.DOG_GIGGLE:
			pass

func select_color():
	color = randi_range(0, 2)
	match color:
		0:
			base_mult = 0
		1:
			base_mult = 0.4
		2:
			base_mult = 0.2

func random_trajectory():
	if randi() % 2:
		flying_left = true
		flip_h = true
	else:
		flying_left = false
		flip_h = false

func hit():
	if state != DuckState.FLYING:
		return
	state = DuckState.HIT
	timer = 30
	match color:
		0:
			game.pointscore += 500
			animation = "green_shock"
		1:
			game.pointscore += 1500
			animation = "red_shock"
		2:
			game.pointscore += 1000
			animation = "blue_shock"

func respawn_duck():
	global_position = duck_spawner.global_position + Vector2(randi_range(-50, 50), 0)
	select_color()
	random_trajectory()
	flying_down = false
	state = DuckState.NEUTRAL
	
func reroll_random_offsets():
	random_x_offset = randf_range(-0.5, 0.5)
	random_y_offset = randf_range(-0.5, 0.5)
