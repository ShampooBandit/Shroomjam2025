extends Node2D

var item_id : int = 2
@export var locked_door : Node2D

func unlock_door() -> void:
	locked_door.queue_free()
