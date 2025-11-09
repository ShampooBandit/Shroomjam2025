extends Node2D
class_name DuckHuntGame

var level = 1
var shots = 3
var duck = 1
var successes = []
var score = 0
var pointscore = 0
var flyingcurrently = false

var counter = 0

@export var ammo_label: Label
@export var score_label: Label
@export var ducks_label: Label

func _process(_delta: float):
	match shots:
		3:
			ammo_label.text = "333"
		2:
			ammo_label.text = "330"
		1:
			ammo_label.text = "300"
		0:
			ammo_label.text = "000"
			
	var finalstring = ""
	for i in range(10):
		if score > i:
			finalstring += "2"
		else:
			finalstring += "1"
	if flyingcurrently and counter % 32 > 15:
		finalstring[score] = "0"
	ducks_label.text = finalstring
	
	var scoretext = ""
	scoretext = str(pointscore)
	while scoretext.length() < 6:
		scoretext = "0" + scoretext
	score_label.text = scoretext
	
func _physics_process(_delta: float):
	counter += 1
