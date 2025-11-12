extends Node

func play_sound(_sound: AudioStream, _bus: String, _volume_level: float = 1.0) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.finished.connect(player.queue_free)
	player.stream = _sound
	player.bus = _bus
	player.volume_linear = _volume_level
	player.play()
