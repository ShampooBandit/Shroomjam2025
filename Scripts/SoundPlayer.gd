extends Node

var title_player : AudioStreamPlayer = AudioStreamPlayer.new()

func play_sound(_sound: AudioStream, _bus: String, _volume_level: float = 1.0) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.finished.connect(player.queue_free)
	player.stream = _sound
	player.bus = _bus
	player.volume_linear = _volume_level
	player.play()
	
	return player

func title_music(_sound: AudioStream) -> AudioStreamPlayer:
	if !title_player.playing:
		if !title_player.get_parent():
			add_child(title_player)
		title_player.stream = _sound
		title_player.volume_linear = 0.8
		title_player.bus = "Master"
		title_player.play()
	return title_player
