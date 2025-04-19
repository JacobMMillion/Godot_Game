extends Area2D

@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"../player"

func _on_body_entered(body: Node2D) -> void:
	print("kill zone entered by: ", body.name)
	
	# UPDATED: rolls no longer kill slimes
	# Check if the body is the player
	#if body.has_method("is_player_rolling"):
		## If player is rolling, kill the slime
		#if body.is_player_rolling():
			#print("Player is rolling - destroying slime!")
			#
			## Get the grandparent node (the actual slime root)
			#var animated_sprite = get_parent()  # This is AnimatedSprite2D
			#var slime_root = animated_sprite.get_parent()  # This is the actual slime object
			#
			#if slime_root:
				#print("Destroying slime: ", slime_root.name)
				#slime_root.queue_free()
			#return
	
	# Otherwise proceed with normal death sequence for the player
	Engine.time_scale = 0.5 # slow down
	body.get_node("CollisionShape2D").queue_free() # remove player collision
	player.die()
	
	timer.start()
	

func _on_timer_timeout() -> void:
	Engine.time_scale = 1 # reset time scale
	get_tree().reload_current_scene()
