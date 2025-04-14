extends Area2D

@export var speed: float = 200.0
@export var max_lifetime: float = 2.5

var lifetime: float
var direction: Vector2 = Vector2.ZERO

@onready var player: Node2D = get_node("/root/level1/player")
const EXPLOSION_SCENE = preload("res://scenes/projectile_explosion.tscn")
const LAUNCH_SCENE = preload("res://scenes/projectile_launch.tscn")

func _ready() -> void:
	lifetime = max_lifetime
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))
	
	# Instantiate the launch animation effect
	var launch_effect = LAUNCH_SCENE.instantiate()
	launch_effect.global_position = global_position
	get_tree().current_scene.add_child(launch_effect)

func _physics_process(delta: float) -> void:
	# Determine the movement direction: toward the player if possible or fallback
	var move_dir: Vector2
	if is_instance_valid(player):
		move_dir = (player.global_position - global_position).normalized()
	else:
		move_dir = direction

	# Move the arm
	position += move_dir * speed * delta

	# Smoothly rotate the arm toward the movement direction
	rotation = lerp_angle(rotation, move_dir.angle(), 5 * delta)

	# Decrement lifetime and remove the node once expired
	lifetime -= delta
	if lifetime <= 0.0:
		# Instantiate the explosion and add it to the current scene
		var explosion = EXPLOSION_SCENE.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		print(" → player hit by projectile")
		
		# Instantiate the explosion and add it to the current scene
		var explosion = EXPLOSION_SCENE.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()
		body.die()
