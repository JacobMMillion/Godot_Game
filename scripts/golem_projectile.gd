extends Area2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	# optional: queue_free() if off‐screen

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(20)  # or whatever
		queue_free()
