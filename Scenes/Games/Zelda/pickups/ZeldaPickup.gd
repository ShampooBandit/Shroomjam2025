extends Node2D

@onready var sprite := $Sprite2D

func _ready() -> void:
	pass

func _on_area_2d_body_entered(body):
	if body is ZeldaPlayer:
		if body.hp < body.maxhp:
			body.hp += 1
		queue_free()
