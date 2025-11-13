extends Node
class_name Detection

var approach_sfx := preload("res://SFX/steps_approach.ogg")
var leave_sfx := preload("res://SFX/steps_leave.ogg")
var closing_sfx := preload("res://SFX/door_closing2.ogg")
var opening_sfx := preload("res://SFX/door_opening.mp3")

## The least time possible between two attacks.
@export var min_time_between_attacks = 10
## The most time possible between two attacks.
@export var max_time_between_attacks = 15
## How long from the warning animation to the actual attack happening
@export var grace_period = 1.75
## How long will attacks last at minimum
@export var min_time_of_attack = 2
## How long will attacks last at maximum
@export var max_time_of_attack = 6
## Chance of immediately opening the door again
@export var instant_open_chance = 1

@export var game_loop: GameLoop

var timer = 60
var is_stopped : bool = false

signal CaughtGaming

enum AttackState {IDLE, GRACE, ATTACKING, RECOVERY}

var attack_state = AttackState.IDLE

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	reset_ai()

func _physics_process(_delta: float) -> void:
	if !is_stopped:
		timer -= 1 # Always deduct the timer every 1/60th of a second
		match attack_state:
			AttackState.IDLE:
				# Play door closing anim
				if timer <= 0:
					# Transition to grace period
					timer = grace_period * 60
					attack_state = AttackState.GRACE
					SoundPlayer.play_sound(opening_sfx, "World")
					anim_player.play("opening")
			AttackState.GRACE:
				# Play door opening anim
				if timer <= 0:
					# Transition to actual attack phase
					timer = randi_range(min_time_of_attack * 60, max_time_of_attack * 60)
					attack_state = AttackState.ATTACKING
					# Show silhouette
			AttackState.ATTACKING:
				if game_loop.show_game == true:
					#lose()
					pass
				if timer <= 0:
					# Transition to recovery
					attack_state = AttackState.RECOVERY
					SoundPlayer.play_sound(closing_sfx, "World")
					anim_player.play("closing")
					timer = 30
			AttackState.RECOVERY:
				# Does nothing for now
				if timer <= 0:
					#if randi_range(): 
					timer = randi_range(min_time_between_attacks * 60, max_time_between_attacks * 60)
					attack_state = AttackState.IDLE

func reset_anim() -> void:
	anim_player.play("RESET")

func reset_ai() -> void:
	timer = randi_range(min_time_between_attacks * 60, max_time_between_attacks * 60)
	attack_state = AttackState.IDLE
	start_ai()

func stop_ai() -> void:
	is_stopped = true

func start_ai() -> void:
	is_stopped = false

func change_ai(_min_attack_spacing: int, _max_attack_spacing: int, _grace: float, 
_min_attack_duration: int, _max_attack_duration: int) -> void:
	min_time_between_attacks = _min_attack_spacing
	## The most time possible between two attacks.
	max_time_between_attacks = _max_attack_spacing
	## How long from the warning animation to the actual attack happening
	grace_period = _grace
	## How long will attacks last at minimum
	min_time_of_attack = _min_attack_duration
	## How long will attacks last at maximum
	max_time_of_attack = _max_attack_duration

func lose() -> void:
	stop_ai()
	CaughtGaming.emit()
	#print("Caught!")
