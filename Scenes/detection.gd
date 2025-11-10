extends Node
class_name Detection

## The least time possible between two attacks.
@export var min_time_between_attacks = 5
## The most time possible between two attacks.
@export var max_time_between_attacks = 10
## How long from the warning animation to the actual attack happening
@export var grace_period = 2
## How long will attacks last at minimum
@export var min_time_of_attack = 5
## How long will attacks last at maximum
@export var max_time_of_attack = 10

@export var light_from_door: ColorRect
@export var game_loop: GameLoop

var timer = 0

enum AttackState {IDLE, GRACE, ATTACKING, RECOVERY}

var attack_state = AttackState.IDLE

func _physics_process(delta: float) -> void:
	timer -= 1 # Always deduct the timer every 1/60th of a second
	match attack_state:
		AttackState.IDLE:
			# Play door closing anim
			light_from_door.size.x = lerp(light_from_door.size.x, 0.0, 0.1)
			if timer <= 0:
				# Transition to grace period
				timer = grace_period * 60
				attack_state = AttackState.GRACE
		AttackState.GRACE:
			# Play door opening anim
			light_from_door.size.x = lerp(light_from_door.size.x, 138.0, 0.1)
			if timer <= 0:
				# Transition to actual attack phase
				timer = randi_range(min_time_of_attack * 60, max_time_of_attack * 60)
				attack_state = AttackState.ATTACKING
		AttackState.ATTACKING:
			if game_loop.show_game == true:
				lose()
			if timer <= 0:
				# Transition to recovery
				attack_state = AttackState.RECOVERY
		AttackState.RECOVERY:
			# Does nothing for now
			timer = randi_range(min_time_between_attacks * 60, max_time_between_attacks * 60)
			attack_state = AttackState.IDLE
			
			
func lose():
	pass
