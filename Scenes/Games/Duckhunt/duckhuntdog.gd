extends AnimatedSprite2D
class_name DuckHuntDog

var success_sfx := preload("res://SFX/Duckhunt/successful_shot.wav")
var miss_sfx := preload("res://SFX/Duckhunt/missed_shot.wav")

var moving_up = false
var timer = 0
var is_laughing : bool = false

@export var dog_start_pos: Node2D
@export var dog_end_pos: Node2D

@export var game: DuckHuntGame

func _ready():
	play()

func _physics_process(_delta: float):
	if moving_up and global_position > dog_end_pos.global_position:
		position.y -= 1
	elif !moving_up and global_position < dog_start_pos.global_position:
		position.y += 1
		if global_position >= dog_start_pos.global_position:
			is_laughing = false
	timer -= 1
	if timer <= 0:
		moving_up = false
		
	if game.gamemode != game.Gamemode.NORMAL:
		hide()
	else:
		show()
	
func hit():
	SoundPlayer.play_sound(success_sfx, "Console")
	animation = "happy_1"
	moving_up = true
	timer = 60
	pass
	
func miss():
	SoundPlayer.play_sound(miss_sfx, "Console")
	animation = "giggling"
	moving_up = true
	timer = 60
	is_laughing = true
	pass
