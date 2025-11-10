extends Node2D

@onready var commercials : CanvasLayer = find_child("Commercials")
@onready var platformer : Node2D = find_child("PlatformerGame")
@onready var duckhunt : Node2D = find_child("DuckhuntGame")
@onready var zelda : Node2D = find_child("ZeldaGame")
@onready var channel_label : CanvasLayer = find_child("ChannelLabel")

#0 - Platformer
#1 - Duck Hunt
#2 - Zelda
#etc
var current_game : int = 2
@onready var game_list : Array = [platformer, duckhunt, zelda]
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
	zelda.visible = true
	channel_label_timer = 120
	# set process_mode = Node.PROCESS_MODE_DISABLED for each game that isn't running and make them not visible
	platformer.process_mode = Node.PROCESS_MODE_DISABLED
	platformer.disable_tilemaps()
	duckhunt.process_mode = Node.PROCESS_MODE_DISABLED
	zelda.find_child("Camera2D").make_current()
	
func _process(_delta: float) -> void:
	if channel_label_timer > 0:
		channel_label_timer -= 1
	else:
		channel_label.visible = false
	
	if Input.is_action_just_pressed("ToggleCommercial"):
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
