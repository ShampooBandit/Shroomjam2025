class_name PlatformerBoss extends CharacterBody2D

var starting_pos : Vector2

func _ready() -> void:
	starting_pos = position

func _physics_process(_delta: float):
	pass

func respawn():
	position = starting_pos
