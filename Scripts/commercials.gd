class_name Commercials extends CanvasLayer

var video_array : Array = []
var video_index : int = 0
@onready var video_player : VideoStreamPlayer = $Control/CenterContainer/VideoStreamPlayer

func _ready() -> void:
	var video_folder : Array = ResourceLoader.list_directory("res://Videos")
	var folder_path = "res://Videos/"
	for video_name in video_folder:
		video_array.append(load(folder_path + video_name))
	
	video_player.stream = video_array[0]
	video_player.play()

func _go_to_next_commercial() -> void:
	video_index += 1
	if video_index >= len(video_array):
		video_index = 0
		
	video_player.stop()
	video_player.stream = video_array[video_index]
	video_player.play()

func _on_video_stream_player_finished():
	_go_to_next_commercial()
