extends VBoxContainer
class_name GalleryVideoContainer

@export var video_name = ""

@export var video_player: GalleryPlayer

func _on_texture_rect_pressed() -> void:
	video_player.play_video("res://Videos/" + video_name + ".ogv")
