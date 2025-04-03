extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
# Adjust the path below to match where your player node is in the scene tree
@onready var player: Node2D = get_node("/root/level1/player")

const SPEED = 40

func _ready():
	# Add to slimes group
	add_to_group("slimes")

func _process(delta: float) -> void:
	# Make sure the player exists
	if not player:
		return
	
	# Check the player's position relative to the enemy
	if player.position.x < position.x and not ray_cast_left.is_colliding():
		# Move left
		position.x -= SPEED * delta
		animated_sprite.flip_h = true
	elif player.position.x > position.x and not ray_cast_right.is_colliding():
		# Move right
		position.x += SPEED * delta
		animated_sprite.flip_h = false
