extends Node2D

@export var item_id : int = 0
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	match item_id:
		0:
			sprite.frame = 2
		1:
			sprite.frame = 5
		3:
			sprite.frame = 8
