extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
# Adjust the path below to match where your player node is in the scene tree
@onready var player: Node2D = get_node("/root/level1/player")

const SPEED = 60

func _process(delta: float) -> void:
	# Make sure the player exists
	if not player:
		return
	
	# Check the player's position relative to the enemy
	if player.position.x < position.x:
		# Move left
		position.x -= SPEED * delta
		animated_sprite.flip_h = true
	elif player.position.x > position.x:
		# Move right
		position.x += SPEED * delta
		animated_sprite.flip_h = false
