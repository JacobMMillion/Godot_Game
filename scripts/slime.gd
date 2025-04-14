extends Area2D

@onready var ray_cast_right: RayCast2D    = $RayCastRight
@onready var ray_cast_left:  RayCast2D    = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var health_bar: ProgressBar = $HealthBarLayer/HealthBar

const SPEED = 60
var direction = 1

var MAX_HEALTH:    int = 100
var current_health: int = 100

func _ready() -> void:
	add_to_group("enemies")
	health_bar.custom_minimum_size = Vector2(64, 6)
	health_bar.min_value = 0
	health_bar.max_value = MAX_HEALTH
	health_bar.value = current_health

func _process(delta: float) -> void:
	# Movement logic
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	position.x += direction * SPEED * delta

	# World → screen using the canvas transform
	var canvas_t: Transform2D = get_viewport().get_canvas_transform()
	var screen_pos: Vector2  = canvas_t * global_position

	# Center the ProgressBar by subtracting half its width
	var bar_w: float = health_bar.size.x
	health_bar.position = screen_pos + Vector2(-bar_w * 0.5, -45)

# Called when the enemy takes damage.
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health
	if current_health == 0:
		die()
	else:
		call_deferred("update")  # redraw the health bar with the new value

func die() -> void:
	queue_free()
