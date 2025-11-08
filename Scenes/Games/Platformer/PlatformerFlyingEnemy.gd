class_name PlatformerFlyingEnemy extends CharacterBody2D

var dir : int = 1
var speed : int = 50
var stomped : bool = false
var top_y : float = 0
var bottom_y : float = 0

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("walk")
	top_y = position.y - 48.0
	bottom_y = position.y + 48.0

func _physics_process(_delta: float) -> void:
	if !stomped:
		if dir > 0:
			velocity.y = speed
			if position.y >= bottom_y:
				dir = -1
		else:
			velocity.y = -speed
			if position.y <= top_y:
				dir = 1
	else:
		velocity.y = 0
	
	move_and_slide()
	
func getStomped() -> void:
	stomped = true
	anim_player.play("die")

func _on_animation_player_animation_finished(_anim_name):
	if _anim_name == "die":
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	elif _anim_name == "RESET":
		anim_player.play("walk")
		
func respawn() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	stomped = false
	anim_player.play("RESET")
	visible = true
