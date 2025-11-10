extends Node2D

@export var item_id : int = 0
@onready var sprite := $Sprite2D

func _ready() -> void:
	match item_id:
		0:
			sprite.frame = 0
