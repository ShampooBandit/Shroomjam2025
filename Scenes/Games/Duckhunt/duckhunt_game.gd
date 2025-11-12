extends Node2D
class_name DuckHuntGame

var level = 1
var shots = 3
var duck = 0
var clay1 = 0
var clay2 = 0
var successes = [false, false, false, false, false, false, false, false, false, false]
var score = 0
var pointscore = 0
var flyingcurrently = false
var threshold = 6

enum Gamemode {NORMAL, CLAY, HOGAN}

var gamemode = Gamemode.NORMAL

var counter = 0

@export var ammo_label: Label
@export var score_label: Label
@export var ducks_label: Label
@export var threshold_label: Label
@export var level_label: Label
<<<<<<< Updated upstream

@export var foreground: Sprite2D
@export var background: ColorRect
@export var clay_background: Sprite2D

<<<<<<< Updated upstream
func _process(delta: float):
	match shots:
		3:
			ammo_label.text = "333"
		2:
			ammo_label.text = "330"
		1:
			ammo_label.text = "300"
		0:
			ammo_label.text = "000"
=======
=======

@export var foreground: Sprite2D
@export var background: ColorRect
@export var clay_background: Sprite2D

>>>>>>> Stashed changes
func _process(_delta: float):
	match level:
		1, 4:
			gamemode = Gamemode.NORMAL
		2, 5:
			gamemode = Gamemode.CLAY
		3, 6:
			gamemode = Gamemode.HOGAN
	match gamemode:
		Gamemode.NORMAL:
			clay_background.hide()
			foreground.position.x = 768.0
			background.color = Color("63adff")
			match shots:
				3:
					ammo_label.text = "333"
				2:
					ammo_label.text = "330"
				1:
					ammo_label.text = "300"
				0:
					ammo_label.text = "000"
		Gamemode.CLAY:
			clay_background.show()
			foreground.position.x = 256.0
			background.color = Color("4acede")
			match shots:
				3:
					ammo_label.text = "777"
				2:
					ammo_label.text = "770"
				1:
					ammo_label.text = "700"
				0:
					ammo_label.text = "000"
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
			
	if duck >= 10:
		if score >= threshold:
			level += 1
		restart_game()
	
	
	
	
	var finalstring = ""
	for i in range(10):
		match gamemode:
			Gamemode.NORMAL:
				if successes[i] == true:
					finalstring += "2"
				else:
					finalstring += "1"
			Gamemode.CLAY:
				if successes[i] == true:
					finalstring += "6"
				else:
					finalstring += "5"
		
	if flyingcurrently and gamemode == Gamemode.NORMAL and counter % 32 > 15:
		finalstring[duck] = "0"
	if gamemode == Gamemode.CLAY and counter % 32 > 15:
		finalstring[duck] = "0"
		finalstring[duck+1] = "0"
	ducks_label.text = finalstring
	
	var scoretext = ""
	scoretext = str(pointscore)
	while scoretext.length() < 6:
		scoretext = "0" + scoretext
	score_label.text = scoretext
	
<<<<<<< Updated upstream
<<<<<<< Updated upstream
func _physics_process(delta: float):
=======
=======
>>>>>>> Stashed changes
	var thresholdtext = ""
	for i in range(10):
		if threshold > i:
			match gamemode:
				Gamemode.NORMAL:
					thresholdtext += "4"
				Gamemode.CLAY:
					thresholdtext += "8"
		else:
			thresholdtext += "0"
	threshold_label.text = thresholdtext
	
	level_label.text = str(level)
	
func _physics_process(_delta: float):
>>>>>>> Stashed changes
	counter += 1
	
func hide_game() -> void:
	visible = false
	
func show_game() -> void:
	visible = true

func disable_tilemaps() -> void:
	pass

func enable_tilemaps() -> void:
	pass

func restart_game() -> void:
	score = 0
	pointscore = 0
	shots = 3
	duck = 0
	successes = [false, false, false, false, false, false, false, false, false, false]

func earn_point() -> void:
	successes[duck] = true
	duck += 1
	score += 1
	
func earn_first_point() -> void:
	successes[duck] = true
	score += 1
	
func earn_second_point() -> void:
	successes[duck+1] = true
	score += 1
