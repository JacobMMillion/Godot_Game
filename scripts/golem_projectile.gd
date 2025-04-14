extends Area2D

@export var speed: float = 200.0
@export var max_lifetime: float = 2.5

var lifetime: float
var direction: Vector2 = Vector2.ZERO

@onready var player: Node2D = get_node("/root/level1/player")

func _ready() -> void:
	lifetime = max_lifetime
	# Make sure the `body_entered` signal is connected to `_on_Area2D_body_entered`
	# either in the editor or via code like:
	# connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

func _physics_process(delta: float) -> void:
	# Home in on the player if valid
	if is_instance_valid(player):
		var dir = (player.global_position - global_position).normalized()
		position += dir * speed * delta
	else:
		# fallback movement
		position += direction * speed * delta

	# Self‑destruct after lifetime expires
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("player hit")
		#body.take_damage(20)
		queue_free()
