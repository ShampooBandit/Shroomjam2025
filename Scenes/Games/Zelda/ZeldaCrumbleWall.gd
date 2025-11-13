class_name ZeldaCrumbleWall extends CharacterBody2D

@onready var hitbox : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $WallSprite
@onready var o_sprite : Sprite2D = $OverSprite

func _ready() -> void:
	pass

func destroy() -> void:
	hitbox.disabled = true
	sprite.frame = 1
	o_sprite.visible = true
