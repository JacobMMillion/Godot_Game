extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right:   RayCast2D        = $RayCastRight
@onready var ray_cast_left:    RayCast2D        = $RayCastLeft
@onready var player:           Node2D           = get_node("/root/level1/player")

@onready var health_bar:       ProgressBar      = $HealthBarLayer/HealthBar
const   MAX_HEALTH:    int     = 100
var     current_health: int    = MAX_HEALTH

const SPEED = 40

func _ready():
	add_to_group("enemies")

	# ─── INITIALIZE HEALTH BAR ────────────────────────────────────────────
	health_bar.custom_minimum_size = Vector2(64, 6)
	health_bar.min_value = 0
	health_bar.max_value = MAX_HEALTH
	health_bar.value     = current_health
	# ────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	# Make sure the player exists
	if not player:
		return

	# ─── YOUR EXISTING AI MOVEMENT LOGIC ───────────────────────────────────
	if player.position.x < position.x and not ray_cast_left.is_colliding():
		position.x -= SPEED * delta
		animated_sprite.flip_h = true
	elif player.position.x > position.x and not ray_cast_right.is_colliding():
		position.x += SPEED * delta
		animated_sprite.flip_h = false
	# ────────────────────────────────────────────────────────────────────────

	# ─── UPDATE HEALTH BAR SCREEN POSITION ────────────────────────────────
	var canvas_t: Transform2D = get_viewport().get_canvas_transform()
	var screen_pos: Vector2  = canvas_t * global_position
	var bar_w: float         = health_bar.size.x
	health_bar.position     = screen_pos + Vector2(-bar_w * 0.5, -45)
	# ────────────────────────────────────────────────────────────────────────

# ─── ADD THESE FUNCTIONS AT THE BOTTOM ─────────────────────────────────
func take_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, MAX_HEALTH)
	health_bar.value = current_health
	if current_health == 0:
		die()

func die() -> void:
	queue_free()
# ────────────────────────────────────────────────────────────────────────
