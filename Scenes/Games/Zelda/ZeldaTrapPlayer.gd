class_name ZeldaTrapPlayer extends CharacterBody2D

func _ready() -> void:
	disable()

func enable() -> void:
	show()
	set_collision_layer_value(1, true)
	
func disable() -> void:
	hide()
	set_collision_layer_value(1, false)

func _physics_process(_delta) -> void:
	pass
	#if visible:
		#var last_collision = get_last_slide_collision()
		#if last_collision:
			#var last_collider = last_collision.get_collider()
			#if last_collider is ZeldaPlayer:
				#last_collider.global_position.x = global_position.x + 32.0
