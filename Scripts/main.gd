extends Node2D

@onready var commercials : CanvasLayer = find_child("Commercials")
@onready var platformer : Node2D = find_child("PlatformerGame")
@onready var channel_label : CanvasLayer = find_child("ChannelLabel")

#0 - Platformer
#1 - Duck Hunt
#2 - Excitebike
#etc
var current_game : int = 0
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
	platformer.visible = true
	channel_label_timer = 120
	# set process_mode = Node.PROCESS_MODE_DISABLED for each game that isn't running and make them not visible
	
func _process(_delta: float) -> void:
	if channel_label_timer > 0:
		channel_label_timer -= 1
	else:
		channel_label.visible = false
	
	if Input.is_action_just_pressed("ToggleCommercial"):
		if show_game:
			platformer.visible = false
			commercials.visible = true
			AudioServer.set_bus_mute(bus_ids[2], true)
			AudioServer.set_bus_mute(bus_ids[1], false)
			channel_label.get_child(0).text = "Ch. 4"
			channel_label.visible = true
			channel_label_timer = 120
			show_game = false
		else:
			platformer.visible = true
			commercials.visible = false
			AudioServer.set_bus_mute(bus_ids[2], false)
			AudioServer.set_bus_mute(bus_ids[1], true)
			channel_label.get_child(0).text = "Ch. 3"
			channel_label.visible = true
			channel_label_timer = 120
			show_game = true
