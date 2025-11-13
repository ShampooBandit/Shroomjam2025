extends Node2D
class_name GameLoop

var title_song : AudioStream = preload("res://SFX/title.ogg")

@onready var commercials : Commercials = find_child("Commercials")
@onready var platformer : PlatformerGame = find_child("PlatformerGame")
@onready var duckhunt : DuckHuntGame = find_child("DuckhuntGame")
@onready var zelda : ZeldaGame = find_child("ZeldaGame")
@onready var channel_label : CanvasLayer = find_child("ChannelLabel")
@onready var detection : Detection = find_child("Detection")
@onready var screen_cover : ColorRect = find_child("ScreenCover")
@onready var canvas2 : CanvasLayer = find_child("CanvasLayer2")
@onready var hands : Hands = find_child("Hands")
@onready var end_screen : Control = find_child("MainEndScreen")

#0 - Platformer
#1 - Duck Hunt
#2 - Zelda
#etc
#During duck hunt, have the door open between rounds or some other predictable pattern
#During mario/zelda door becomes random and more aggressive
var current_game : int = 0
@onready var game_list : Array = [duckhunt, platformer, zelda]
var bus_ids : Array = [0,0,0,0]
var show_game : bool = true
var channel_label_timer : int = 0
var is_caught : bool = false
var hiding_screen : bool = false
var timer : int = 0
var is_currentgame_complete : bool = false
var going_to_next_game : bool = false
var won_the_game : bool = false

func _stop_ai() -> void:
	detection.reset_anim()
	detection.stop_ai()

func _ready() -> void:
	screen_cover.modulate.a = 0.0
	
	duckhunt.beat_game.connect(beat_nes_game)
	platformer.beatGame.connect(beat_nes_game)
	zelda.ZeldaGameBeat.connect(beat_nes_game)
	zelda.StopAI.connect(_stop_ai)
	detection.CaughtGaming.connect(lose_game)
	
	bus_ids[0] = AudioServer.get_bus_index("Master")
	bus_ids[1] = AudioServer.get_bus_index("Commercial")
	bus_ids[2] = AudioServer.get_bus_index("Console")
	bus_ids[3] = AudioServer.get_bus_index("World")
	AudioServer.set_bus_mute(bus_ids[1], true)
	AudioServer.set_bus_volume_db(bus_ids[1], -5)
	channel_label_timer = 120
	# set process_mode = Node.PROCESS_MODE_DISABLED for each game that isn't running and make them not visible
	platformer.disable_tilemaps()
	platformer.hide_game()
	platformer.process_mode = Node.PROCESS_MODE_DISABLED
	zelda.disable_tilemaps()
	zelda.hide_game()
	zelda.process_mode = Node.PROCESS_MODE_DISABLED
	duckhunt.visible = true
	
func _process(_delta: float) -> void:
	if is_currentgame_complete:
		_between_game_process(_delta)
	else:
		_gameplay_process(_delta)
	
func _between_game_process(_delta: float) -> void:
	if going_to_next_game:
		timer -= 1
		if timer <= 1:
			is_currentgame_complete = false
			go_to_next_game()
			going_to_next_game = false
	else:
		if Input.is_action_just_pressed("Start"):
			detection.reset_ai()
			timer = 15
			going_to_next_game = true
	
func _gameplay_process(_delta: float) -> void:
	if channel_label_timer > 0:
		channel_label_timer -= 1
	else:
		channel_label.visible = false
	
	if is_caught:
		if hiding_screen:
			var tween = get_tree().create_tween()
			tween.tween_property(screen_cover, "modulate:a", 1.0, 1.0)
			tween.play()
			await tween.finished
			tween.kill()
			hiding_screen = false
			timer = 120
			detection.reset_anim()
		else:
			timer -= 1
			if timer <= 0:
				is_caught = false
				game_list[current_game].reset_game()
				AudioServer.set_bus_mute(bus_ids[2], false)
				game_list[current_game].process_mode = Node.PROCESS_MODE_INHERIT
				var tween = get_tree().create_tween()
				tween.tween_property(screen_cover, "modulate:a", 0.0, 1.0)
				tween.play()
				await tween.finished
				tween.kill()
				detection.reset_ai()
				hands.anim_player.play(hands.anim_player.current_animation)
	else:
		if !won_the_game:
			#if Input.is_action_just_pressed("Switch Game"):
			#	beat_nes_game()
			if Input.is_action_just_pressed("ToggleCommercial"):
				if show_game:
					hands.anim_player.play("remote")
					game_list[current_game].hide_game()
					commercials.visible = true
					AudioServer.set_bus_mute(bus_ids[2], true)
					AudioServer.set_bus_mute(bus_ids[1], false)
					channel_label.get_child(0).text = "Ch. 4"
					channel_label.visible = true
					channel_label_timer = 120
					show_game = false
				else:
					if current_game == 0:
						hands.anim_player.play("zapper")
					else:
						hands.anim_player.play("nes")
					game_list[current_game].show_game()
					commercials.visible = false
					AudioServer.set_bus_mute(bus_ids[2], false)
					AudioServer.set_bus_mute(bus_ids[1], true)
					channel_label.get_child(0).text = "Ch. 3"
					channel_label.visible = true
					channel_label_timer = 120
					show_game = true
			elif Input.is_action_just_pressed("NextCommercial") and commercials.visible:
				#commercials._go_to_next_commercial()
				commercials._go_to_random_commercial()

func beat_nes_game() -> void:
	is_currentgame_complete = true
	detection.reset_anim()
	detection.stop_ai()

func go_to_next_game() -> void:
	match current_game:
		0:
			duckhunt.disable_tilemaps()
			duckhunt.hide_game()
			duckhunt.queue_free()
			platformer.process_mode = Node.PROCESS_MODE_ALWAYS
			platformer.enable_tilemaps()
			platformer.show_game()
			platformer.find_child("Camera2D").make_current()
			hands.anim_player.play("nes")
		1:
			platformer.disable_tilemaps()
			platformer.hide_game()
			platformer.queue_free()
			zelda.process_mode = Node.PROCESS_MODE_ALWAYS
			zelda.enable_tilemaps()
			zelda.show_game()
			zelda.find_child("Camera2D").make_current()
			detection.change_ai(25, 45, 1.75, 2, 4)
		2:
			win_game()
	current_game += 1

func win_game() -> void:
	won_the_game = true
	var tween = get_tree().create_tween()
	tween.tween_property(screen_cover, "modulate:a", 1.0, 2.0)
	tween.play()
	await tween.finished
	end_screen.visible = true
	zelda.queue_free()
	tween.kill()
	go_to_end()

func go_to_end() -> void:
	SoundPlayer.title_music(title_song)
	var tween = get_tree().create_tween()
	tween.tween_property(screen_cover, "modulate:a", 0.0, 2.0)
	tween.play()

func lose_game() -> void:
	game_list[current_game].process_mode = Node.PROCESS_MODE_DISABLED
	AudioServer.set_bus_mute(bus_ids[2], true)
	hands.anim_player.pause()
	is_caught = true
	hiding_screen = true
