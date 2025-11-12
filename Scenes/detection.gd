extends Node
class_name Detection

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
	pass

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
					lose()
				if timer <= 0:
					# Transition to recovery
					attack_state = AttackState.RECOVERY
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

func lose() -> void:
	stop_ai()
	CaughtGaming.emit()
	#print("Caught!")
