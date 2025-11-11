extends Node2D

@export var teleport_cam_position : Vector2
@export var teleport_player_position : Vector2
@export var in_building : bool = true

func _on_area_2d_body_entered(body):
	body.on_exit(teleport_player_position, teleport_cam_position, in_building)
