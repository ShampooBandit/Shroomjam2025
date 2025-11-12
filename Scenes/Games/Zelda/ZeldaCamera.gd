class_name ZeldaCamera extends Camera2D

signal TransitionStart
signal TransitionComplete

var width : int = 512
var height : int = 320
var dir : int = 0
var move : bool = false

var left_border : float = position.x
var right_border : float = position.x + width
var top_border : float = position.y + 96.0 
var bottom_border : float = position.y + height + 96.0 

var target_pos : Vector2 = position

func _ready() -> void:
	pass
	
func teleport(teleport_pos : Vector2) -> void:
	TransitionStart.emit()
	position = teleport_pos
	left_border = position.x
	right_border = position.x + width
	top_border = position.y + 96.0 
	bottom_border = position.y + height + 96.0

func exit() -> void:
	TransitionComplete.emit()

func _process(_delta: float) -> void:
	if move:
		match dir:
			1:
				position.x -= 6.0
				if position.x <= target_pos.x:
					finish_transition()
			2:
				position.y -= 4.0
				if position.y <= target_pos.y:
					finish_transition()
			3:
				position.x += 6.0
				if position.x >= target_pos.x:
					finish_transition()
			4:
				position.y += 4.0
				if position.y >= target_pos.y:
					finish_transition()
				
func finish_transition() -> void:
	position = target_pos
	move = false
	left_border = position.x
	right_border = position.x + width
	top_border = position.y + 96.0 
	bottom_border = position.y + height + 96.0
	TransitionComplete.emit()

func _on_player_screen_transition(_dir: int):
	TransitionStart.emit()
	move = true
	dir = _dir
	match _dir:
		1:
			target_pos = Vector2(position.x - width, position.y)
		2:
			target_pos = Vector2(position.x, position.y - height)
		3:
			target_pos = Vector2(position.x + width, position.y)
		4:
			target_pos = Vector2(position.x, position.y + height)
