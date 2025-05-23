extends Area2D

# — allow per‑instance tuning of speed & damage —
@export var speed: float = 300
@export var damage: int = 10

var shooter: Node = null  # optional reference to player
var velocity: Vector2 = Vector2.ZERO

# preload your explosion/muzzle‑flash scene
const SMALL_EXPLOSION_SCENE = preload("res://scenes/small_explosion.tscn")

func _ready() -> void:
	# wait one frame so everything’s initialized
	await get_tree().process_frame

	var mini_explosion = SMALL_EXPLOSION_SCENE.instantiate()
	mini_explosion.scale = Vector2(0.2, 0.2)
	mini_explosion.global_position = global_position

	# ← instead of current_scene:
	get_parent().add_child(mini_explosion)

	connect("body_entered", Callable(self, "_on_collision"))
	connect("area_entered", Callable(self, "_on_collision"))

	# if no explicit velocity set, fire straight along local +X
	if velocity == Vector2.ZERO:
		velocity = transform.x * speed

func _process(delta: float) -> void:
	position += velocity * delta

func _on_collision(other: Node) -> void:
	if other.is_in_group("enemies"):
		print(" → hit an enemy!")
		if other.has_method("take_damage"):
			other.take_damage(damage)
		# explosion on impact
		var explosion = SMALL_EXPLOSION_SCENE.instantiate()
		explosion.scale = Vector2(0.4, 0.4)
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
