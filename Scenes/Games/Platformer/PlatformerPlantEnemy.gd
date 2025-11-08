class_name PlatformerPlantEnemy extends CharacterBody2D

var dir : int = 1
var speed : int = 1000
var stomped : bool = false
var top_y : float = 0
var bottom_y : float = 0
var timer : int = 60
var emerged : bool = false
var moving : bool = false

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("walk")
	top_y = position.y - 48.0
	bottom_y = position.y

func _physics_process(_delta: float) -> void:
	if !moving:
		timer -= 1
	if !emerged:
		if timer <= 0:
			velocity.y = -speed * _delta
			moving = true
			if position.y <= top_y:
				velocity.y = 0
				timer = 120
				emerged = true
				moving = false
	else:
		if timer <= 0:
			velocity.y = speed * _delta
			moving = true
			if position.y >= bottom_y:
				velocity.y = 0
				timer = 120
				emerged = false
				moving = false
	
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
	position.y = bottom_y
	timer = 60
	velocity.y = 0
	emerged = false
	moving = false
	anim_player.play("RESET")
	visible = true
