extends VBoxContainer
class_name GalleryVideoContainer

@export var video_name = ""

@export var video_player: GalleryPlayer

@export var label: Label

func _ready():
	label.text = video_name

func _on_texture_rect_pressed() -> void:
	video_player.play_video("res://Videos/" + video_name + ".ogv")
