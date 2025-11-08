extends AnimatedSprite2D
class_name DuckHuntDog

var moving_up = false
var timer = 0

@export var dog_start_pos: Node2D
@export var dog_end_pos: Node2D

func _ready():
	play()

func _physics_process(delta: float):
	if moving_up and global_position > dog_end_pos.global_position:
		position.y -= 1
	elif !moving_up and global_position < dog_start_pos.global_position:
		position.y += 1
	timer -= 1
	if timer <= 0:
		moving_up = false
	
func hit():
	animation = "happy_1"
	moving_up = true
	timer = 60
	pass
	
func miss():
	animation = "giggling"
	moving_up = true
	timer = 60
	pass
