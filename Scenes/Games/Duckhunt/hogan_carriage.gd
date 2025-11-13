extends Node2D
class_name Carriage

var slide_sfx := preload("res://SFX/Duckhunt/cutout_slide.wav")
var hit_sfx := preload("res://SFX/Duckhunt/cutout_shot.wav")
var slide_player : AudioStreamPlayer
var hit_player : AudioStreamPlayer

enum HoganState {WAITING, SHOWN, MISS, EXITING, TRANSITION, PASS}

var hogan_enemy = ["gang1", "gang2", "gang3"]

var hogan_civilian = ["woman", "cop", "detective"]

# 1 on level 3, 2 on level 6.
var difficulty = 1

var hits = 0

@export var game: DuckHuntGame

@export var left_cutout: AnimatedSprite2D
@export var center_cutout: AnimatedSprite2D
@export var right_cutout: AnimatedSprite2D

@export var left_white_square: ColorRect
@export var center_white_square: ColorRect
@export var right_white_square: ColorRect

# Which cutouts are the bad guys?
var badguys = [false, false, false]

var state = HoganState.WAITING

var timer = 0
var tth_timer = 0

func _physics_process(_delta: float) -> void:
	if game.gamemode != game.Gamemode.HOGAN:
		state = HoganState.WAITING # Don't do anything if not the right gamemode
		hide()
		left_white_square.hide()
		center_white_square.hide()
		right_white_square.hide()
		return
	else:
		show()
		left_white_square.show()
		center_white_square.show()
		right_white_square.show()
		game.shots = 999 # Make sure you have infinite ammo
	timer -= 1
	if tth_timer > 0 and state == HoganState.SHOWN:
		tth_timer -= 1
	game.timetohit_display = tth_timer / 60
	if position.x > 0:
		position.x -= 1 # Move the carriage right if unpositioned
	match state:
		HoganState.WAITING:
			if timer <= 0:
				# Select the pattern of the characters
				select_pattern()
				# Make them pop out
				update_anim(left_cutout, badguys[0])
				update_anim(center_cutout, badguys[1])
				update_anim(right_cutout, badguys[2])
				state = HoganState.SHOWN
				tth_timer = game.timetohit * 60
		HoganState.SHOWN:
			if hits >= difficulty:
				# Advance early, the player hit all targets
				state = HoganState.PASS
				timer = 3 * 60
			if tth_timer <= 0:
				# If time's up
				if hits >= difficulty:
					# The player somehow won anyway
					state = HoganState.PASS
					timer = 3 * 60
				else:
					# The player didn't make it in time
					state = HoganState.MISS
					game.hoganmiss()
					game.misses += 1
					timer = 3 * 60
		HoganState.MISS:
			if timer <= 0:
				if hit_player:
					hit_player.stop()
				state = HoganState.EXITING
				left_cutout.animation = "revealing"
				center_cutout.animation = "revealing"
				right_cutout.animation = "revealing"
				timer = 30
		HoganState.PASS:
			if timer <= 0:
				if hit_player:
					hit_player.stop()
				state = HoganState.EXITING
				left_cutout.animation = "revealing"
				center_cutout.animation = "revealing"
				right_cutout.animation = "revealing"
				timer = 30
		HoganState.EXITING:
			if timer <= 0:
				state = HoganState.TRANSITION
				left_cutout.animation = "neutral"
				center_cutout.animation = "neutral"
				right_cutout.animation = "neutral"
				position.x = 200 # Move 200 to the right to start the slide anim
				game.hogan_level += 1 # Next level on the HUD
				# Win condition
				if game.hogan_level > 9:
					if game.misses <= 5:
						game.add_level()
						return
					else:
						game.reset_hogan_on_fail()
				if game.misses > 6:
					game.reset_hogan_on_fail()
				slide_player = SoundPlayer.play_sound(slide_sfx, "Console")
		HoganState.TRANSITION:
			if position.x < 1:
				if slide_player:
					slide_player.stop()
				state = HoganState.WAITING
				timer = randf_range(1.0, 2.0) * 60 # Wait for a random time before showing the enemies
				game.timetohit = snapped(randf_range(2.0, 4.0), 0.1) # Set a random time to hit the enemies
				hits = 0
			
func select_pattern():
	var pattern = 0
	if difficulty == 1:
		pattern = randi_range(1, 3) # Patterns 1-3 have only one enemy
	else:
		pattern = randi_range(4, 6) # Patterns 4-6 have two enemies
	match pattern:
		1:
			badguys = [true, false, false]
		2:
			badguys = [false, true, false]
		3:
			badguys = [false, false, true]
		4:
			badguys = [false, true, true]
		5:
			badguys = [true, false, true]
		6:
			badguys = [true, true, false]

func update_anim(cutout: AnimatedSprite2D, evil: bool):
	if evil:
		cutout.animation = hogan_enemy.pick_random()
	else:
		cutout.animation = hogan_civilian.pick_random()
	cutout.play()
	
func hit(which: int):
	if badguys[which] == true:
		if hit_player:
			hit_player.play()
		else:
			hit_player = SoundPlayer.play_sound(hit_sfx, "Console")
		match which:
			0:
				left_cutout.animation = "spinning"
			1:
				center_cutout.animation = "spinning"
			2:
				right_cutout.animation = "spinning"
		hits += 1
		game.pointscore += 500
	else:
		state = HoganState.MISS
		game.hoganmiss()
		timer = 3 * 60
		game.misses += 1

func reset() -> void:
	#slide_player = SoundPlayer.play_sound(slide_sfx, "Console")
	position.x = 200
	state = HoganState.TRANSITION
	left_cutout.animation = "neutral"
	center_cutout.animation = "neutral"
	right_cutout.animation = "neutral"
