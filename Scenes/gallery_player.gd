extends Panel
class_name GalleryPlayer

@export var vid_player: VideoStreamPlayer
@export var play_pause_button: Button
@export var progress_bar: HSlider

var player_visible = false

var progress_dragged = false

func _physics_process(delta: float):
	if player_visible:
		if modulate.a < 1:
			modulate.a += 0.1
	else:
		if modulate.a > 0:
			modulate.a -= 0.1
	
	if !progress_dragged:
		progress_bar.value = vid_player.stream_position
	progress_bar.max_value = vid_player.get_stream_length()

func play_video(url):
	vid_player.play()
	player_visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_blockbuster_pressed() -> void:
	play_video("dsd")


func _on_play_pause_button_pressed() -> void:
	if vid_player.is_playing():
		vid_player.paused = !vid_player.paused
	else:
		vid_player.play()


func _on_progress_bar_drag_started() -> void:
	progress_dragged = true
	vid_player.paused = true


func _on_progress_bar_drag_ended(value_changed: bool) -> void:
	vid_player.stream_position = progress_bar.value
	vid_player.paused = false
	progress_dragged = false


func _on_close_button_pressed() -> void:
	vid_player.stop()
	vid_player.stream_position = 0
	progress_bar.value = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_visible = false


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
