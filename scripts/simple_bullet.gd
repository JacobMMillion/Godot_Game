extends Area2D

const SPEED = 300
@export var damage: int = 10

# Preload your small explosion scene.
const SMALL_EXPLOSION_SCENE = preload("res://scenes/small_explosion.tscn")

func _ready() -> void:
	# Wait one frame so that the bullet's global position is updated
	await get_tree().process_frame  # Godot 4 syntax for "wait until next frame"

	# Spawn a mini explosion effect (a muzzle flash) when the bullet is created.
	var mini_explosion = SMALL_EXPLOSION_SCENE.instantiate()
	mini_explosion.scale = Vector2(0.2, 0.2)  # Adjust scale for the mini flash
	mini_explosion.global_position = global_position
	get_tree().current_scene.add_child(mini_explosion)

	# Connect both signals to catch PhysicsBody2D and Area2D overlaps.
	connect("body_entered", Callable(self, "_on_collision"))
	connect("area_entered", Callable(self, "_on_collision"))


func _process(delta: float) -> void:
	# Move the bullet in the direction of its local x-axis.
	position += transform.x * SPEED * delta

func _on_collision(other: Node) -> void:
	# Debug: See exactly what you hit
	# print("Bullet collided with: ", other.name, " groups=", other.get_groups())
	if other.is_in_group("enemies"):
		#print(" → hit an enemy!")
		if other.has_method("take_damage"):
			other.take_damage(damage)
			
		# Instantiate the explosion effect at the bullet's current position.
		var explosion = SMALL_EXPLOSION_SCENE.instantiate()
		explosion.global_position = global_position
		explosion.scale = Vector2(0.4, 0.4)
		get_tree().current_scene.add_child(explosion)
		
		queue_free()

# Remove the bullet when it leaves the screen.
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
