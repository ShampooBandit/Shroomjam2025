extends VBoxContainer
class_name GalleryVideoContainer

signal internal_button_pressed

func _on_texture_rect_pressed() -> void:
	internal_button_pressed.emit()
