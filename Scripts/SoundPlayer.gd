extends Node

func play_sound(_sound: AudioStream, _bus: String) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.finished.connect(player.queue_free)
	player.stream = _sound
	player.bus = _bus
	player.play()
