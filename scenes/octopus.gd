extends Node2D


@onready var animated_sprite = $AnimatedSprite2D
@onready var player: Node2D = get_node("/root/level1/player")
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft


const SPEED = 50
const DISTANCE_OFFSET = 5
var direction = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Make sure the player exists
	if not player:
		return
	
	if player.position.x < position.x - DISTANCE_OFFSET and !ray_cast_left.is_colliding():
		# Move left
		position.x -= SPEED * delta
		animated_sprite.flip_h = true
		animated_sprite.play("move")
	elif player.position.x > position.x + DISTANCE_OFFSET and !ray_cast_right.is_colliding():
		# Move right
		position.x += SPEED * delta
		animated_sprite.flip_h = false
		animated_sprite.play("move")
	else:
		animated_sprite.play("attack")
