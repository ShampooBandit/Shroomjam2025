extends Node2D
class_name GameLoop

@onready var commercials : CanvasLayer = find_child("Commercials")
@onready var platformer : Node2D = find_child("PlatformerGame")
@onready var duckhunt : Node2D = find_child("DuckhuntGame")
@onready var zelda : Node2D = find_child("ZeldaGame")
@onready var channel_label : CanvasLayer = find_child("ChannelLabel")

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

func _ready() -> void:
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
	if channel_label_timer > 0:
		channel_label_timer -= 1
	else:
		channel_label.visible = false
	
	if Input.is_action_just_pressed("Switch Game"):
		go_to_next_game()
	elif Input.is_action_just_pressed("ToggleCommercial"):
		if show_game:
			game_list[current_game].hide_game()
			commercials.visible = true
			AudioServer.set_bus_mute(bus_ids[2], true)
			AudioServer.set_bus_mute(bus_ids[1], false)
			channel_label.get_child(0).text = "Ch. 4"
			channel_label.visible = true
			channel_label_timer = 120
			show_game = false
		else:
			game_list[current_game].show_game()
			commercials.visible = false
			AudioServer.set_bus_mute(bus_ids[2], false)
			AudioServer.set_bus_mute(bus_ids[1], true)
			channel_label.get_child(0).text = "Ch. 3"
			channel_label.visible = true
			channel_label_timer = 120
			show_game = true

func go_to_next_game() -> void:
	match current_game:
		0:
			duckhunt.visible = false
			duckhunt.process_mode = Node.PROCESS_MODE_DISABLED
			platformer.enable_tilemaps()
			platformer.show_game()
			platformer.process_mode = Node.PROCESS_MODE_ALWAYS
			platformer.find_child("Camera2D").make_current()
		1:
			platformer.disable_tilemaps()
			platformer.hide_game()
			platformer.process_mode = Node.PROCESS_MODE_DISABLED
			zelda.enable_tilemaps()
			zelda.show_game()
			zelda.find_child("Camera2D").make_current()
			zelda.process_mode = Node.PROCESS_MODE_ALWAYS
		2:
			win_game()
	current_game += 1
			
func win_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/end.tscn")
