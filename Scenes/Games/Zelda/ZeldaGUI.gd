extends CanvasLayer

@export var player : CharacterBody2D

@onready var life_display := $LifeDisplay

func _ready():
	pass

func _on_zelda_game_visibility_changed():
	visible = get_parent().visible

func _process(_delta: float) -> void:
	update_life()
	
func update_life() -> void:
	var hearts = life_display.get_children()
	var j = 0
	for i in range(floor(player.maxhp / 2)):
		hearts[i + 1].frame = 0
		
	for i in range(floor(player.hp / 2)):
		hearts[i + 1].frame = 2
		j = i + 1
		
	if player.hp % 2 != 0 and player.hp > 0:
		hearts[j + 1].frame = 1
