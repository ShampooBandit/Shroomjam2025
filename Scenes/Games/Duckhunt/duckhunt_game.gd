extends Node2D
class_name DuckHuntGame

signal beat_game

var level = 1
var hogan_level = 1
var shots = 3
var duck = 0
var clay1 = 0
var clay2 = 0
var successes = [false, false, false, false, false, false, false, false, false, false]
var score = 0
var pointscore = 0
var highscore = 0
var flyingcurrently = false
var threshold = 6
var timetohit = 1.4
var misses = 0

var timetohit_display = 0

var hogan_miss_screen = false
var hogan_miss_timer = 0

var successtimer = 0

enum Gamemode {NORMAL, CLAY, HOGAN, TRANSITION, TITLE, END}

var gamemode = Gamemode.TITLE

var counter = 0

@export var ammo_label: Label
@export var score_label: Label
@export var ducks_label: Label
@export var threshold_label: Label
@export var level_label: Label

@export var score_label_hogan: Label
@export var high_score_label_hogan: Label
@export var level_label_hogan: Label
@export var tth_label_hogan: Label
@export var tth_label_second_hogan: Label
@export var misses_label_hogan: Label

@export var foreground: Sprite2D
@export var background: ColorRect
@export var clay_background: Sprite2D
@export var hogan_foreground: Sprite2D

@export var success_text: Label
@export var fly_away_text: Label

@export var duck_obj: Duck
@export var clay1_obj: ClayPigeon
@export var clay2_obj: ClayPigeon2
@export var dog: DuckHuntDog
@export var carriage_obj: Carriage

@export var title_screen: TextureRect
@export var end_screen: ColorRect
@export var end_screen_label: Label

func _ready() -> void:
	clay1_obj.state = clay1_obj.ClayState.NEUTRAL
	clay2_obj.state = clay1_obj.ClayState.NEUTRAL

func _process(_delta: float):
	match gamemode:
		Gamemode.NORMAL:
			clay_background.hide()
			foreground.show()
			hogan_foreground.hide()
			foreground.position.x = 768.0
			background.color = Color("63adff")
			score_label.show()
			level_label.show()
			ducks_label.show()
			threshold_label.show()
			ammo_label.show()
			score_label_hogan.hide()
			high_score_label_hogan.hide()
			level_label_hogan.hide()
			tth_label_hogan.hide()
			tth_label_second_hogan.hide()
			misses_label_hogan.hide()
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
			foreground.show()
			hogan_foreground.hide()
			foreground.position.x = 256.0
			background.color = Color("4acede")
			score_label.show()
			level_label.show()
			ducks_label.show()
			threshold_label.show()
			ammo_label.show()
			score_label_hogan.hide()
			high_score_label_hogan.hide()
			level_label_hogan.hide()
			tth_label_hogan.hide()
			tth_label_second_hogan.hide()
			misses_label_hogan.hide()
			match shots:
				3:
					ammo_label.text = "777"
				2:
					ammo_label.text = "770"
				1:
					ammo_label.text = "700"
				0:
					ammo_label.text = "000"
		Gamemode.HOGAN:
			clay_background.hide()
			foreground.hide()
			hogan_foreground.show()
			background.color = Color("271b8f")
			score_label.hide()
			level_label.hide()
			ducks_label.hide()
			threshold_label.hide()
			ammo_label.hide()
			score_label_hogan.show()
			high_score_label_hogan.show()
			level_label_hogan.show()
			tth_label_hogan.show()
			tth_label_second_hogan.show()
			misses_label_hogan.show()
			
		Gamemode.TRANSITION:
			successtimer -= 1
			fly_away_text.hide()
			success_text.show()
			if successtimer <= 0:
				success_text.hide()
				add_level()
				
		Gamemode.TITLE:
			title_screen.show()
			if Input.is_action_just_pressed("Start"):
				gamemode = Gamemode.NORMAL
				title_screen.hide()
				
		Gamemode.END:
			end_screen.show()
			
	if duck >= 10 and !dog.is_laughing:
		if score >= threshold:
			success()
		reset_game()
	
	match level:
		1:
			threshold = 6
		2:
			threshold = 5
		3:
			threshold = 5
		4:
			threshold = 8
		5:
			threshold = 6
		6:
			threshold = 5
	
	
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
		
	if flyingcurrently and gamemode == Gamemode.NORMAL and counter % 32 > 15 and !dog.is_laughing:
		finalstring[duck] = "0"
	if gamemode == Gamemode.CLAY and counter % 32 > 15:
		finalstring[duck] = "0"
		finalstring[duck+1] = "0"
	if gamemode != Gamemode.TRANSITION:
		ducks_label.text = finalstring
	
	var scoretext = ""
	scoretext = str(pointscore)
	while scoretext.length() < 6:
		scoretext = "0" + scoretext
	if gamemode != Gamemode.TRANSITION:
		score_label.text = scoretext
		score_label_hogan.text = scoretext
		if pointscore > highscore:
			high_score_label_hogan.text = scoretext
	
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
	if gamemode != Gamemode.TRANSITION:
		threshold_label.text = thresholdtext
	
	level_label.text = str(level)
	level_label_hogan.text = str(hogan_level)
	
	tth_label_hogan.text = str(int(timetohit_display))
	tth_label_second_hogan.text = str(int(round((timetohit_display - int(timetohit_display))*10)))
	
	misses_label_hogan.text = str(misses)
	
	hogan_miss_timer -= 1
	if hogan_miss_timer <= 0 and hogan_miss_screen == true:
		hogan_miss_screen = false
		hogan_foreground.position.y = 576.5
	
func _physics_process(_delta: float):
	counter += 1
	
func hide_game() -> void:
	visible = false
	
func show_game() -> void:
	visible = true

func disable_tilemaps() -> void:
	pass

func enable_tilemaps() -> void:
	pass

func reset_game() -> void:
	score = 0
	pointscore = 0
	shots = 3
	clay1 = 0
	clay2 = 0
	hogan_level = 1
	misses = 0
	successes = [false, false, false, false, false, false, false, false, false, false]
	duck_obj.state = duck_obj.DuckState.NEUTRAL
	duck_obj.respawn_duck()
	clay1_obj.reset_pigeon()
	#clay2_obj.state = clay2_obj.ClayState.INTRO
	carriage_obj.state = carriage_obj.HoganState.WAITING
	if carriage_obj.hit_player:
		carriage_obj.hit_player.stop()
	if carriage_obj.slide_player:
		carriage_obj.slide_player.stop()
	if gamemode == Gamemode.HOGAN:
		carriage_obj.reset()
	duck = 0
	carriage_obj.position.x = 0
	clay1_obj.has_begun = false
	timetohit = snapped(randf_range(2.0, 4.0), 0.1)
	
func reset_hogan_on_fail() -> void:
	pointscore = 0
	hogan_level = 1
	misses = 0
	carriage_obj.state = carriage_obj.HoganState.TRANSITION
	#carriage_obj.reset()
	carriage_obj.position.x = 0
	carriage_obj.left_cutout.animation = "neutral"
	carriage_obj.center_cutout.animation = "neutral"
	carriage_obj.right_cutout.animation = "neutral"
	if carriage_obj.hit_player:
		carriage_obj.hit_player.stop()
	if carriage_obj.slide_player:
		carriage_obj.slide_player.stop()
	timetohit = snapped(randf_range(2.0, 4.0), 0.1)

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
	
func win_game() -> void:
	gamemode = Gamemode.END
	var endstring = "VICTORY\nSCORE: "
	endstring += str(pointscore)
	end_screen_label.text = endstring
	beat_game.emit()
	
func success() -> void:
	gamemode = Gamemode.TRANSITION
	successtimer = 3 * 60
	
func add_level() -> void:
	level += 1
	match level:
		1, 4:
			clay1_obj.state = clay1_obj.ClayState.NEUTRAL
			clay2_obj.state = clay1_obj.ClayState.NEUTRAL
			gamemode = Gamemode.NORMAL
		2, 5:
			clay1_obj.reset_pigeon()
			#clay2_obj.reset_pigeon()
			gamemode = Gamemode.CLAY
		3, 6:
			clay1_obj.state = clay1_obj.ClayState.NEUTRAL
			clay2_obj.state = clay1_obj.ClayState.NEUTRAL
			gamemode = Gamemode.HOGAN
		7:
			win_game()
	if level == 4:
		duck_obj.hard = true
	if level == 5:
		clay1_obj.hard = true
		clay2_obj.hard = true
	if level == 6:
		carriage_obj.difficulty = 2
			
func hoganmiss() -> void:
	hogan_foreground.position.y = 350.5
	hogan_miss_timer = 5 * 60
	hogan_miss_screen = true
