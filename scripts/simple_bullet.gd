extends Area2D

const SPEED = 300
@export var damage: int = 10

func _ready() -> void:
	# Connect both signals so we catch PhysicsBody2D *and* Area2D overlaps.
	connect("body_entered", Callable(self, "_on_collision"))
	connect("area_entered", Callable(self, "_on_collision"))

func _process(delta: float) -> void:
	# Move the bullet in the direction of its local x-axis.
	position += transform.x * SPEED * delta

func _on_collision(other: Node) -> void:
	# Debug: see exactly what you hit
	# print("Bullet collided with: ", other.name, " groups=", other.get_groups())
	if other.is_in_group("enemies"):
		print(" → hit an enemy!")
		if other.has_method("take_damage"):
			other.take_damage(damage)
		queue_free()

# Remove the bullet when it leaves the screen.
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
