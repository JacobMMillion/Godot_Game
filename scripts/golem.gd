extends StaticBody2D

const DEFAULT_ANIM := "idle"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBarLayer/HealthBar
@onready var collision_shape: CollisionShape2D   = $CollisionShape2D

const SPEED = 60
var direction = 1

var MAX_HEALTH:    int = 200
var current_health: int = 200

var actions = ["defend", "extend_arm", "prepare_laser"]
const MIN_DELAY := 4.0
const MAX_DELAY := 4.0

func _ready() -> void:
	add_to_group("enemies")
	health_bar.custom_minimum_size = Vector2(150, 8)
	health_bar.min_value = 0
	health_bar.max_value = MAX_HEALTH
	health_bar.value = current_health
	
	# action stuff
	randomize()
	_action_loop()
	
# Main loop: wait a bit, pick one, play it + run its logic, wait for it to finish, repeat
func _action_loop() -> void:
	while true:
		# 0) idle
		animated_sprite.play(DEFAULT_ANIM)
		
		# 1) random delay
		var t = randf_range(MIN_DELAY, MAX_DELAY)
		await get_tree().create_timer(t).timeout

		# 2) pick & play
		var action = actions[randi() % actions.size()]
		animated_sprite.play(action)

		# 3) do the side‐effect for that action
		#match action:
			#"defend":
				#_do_defend()
			#"extend_arm":
				#_do_shoot_bullet()
			#"prepare_laser":
				#_do_shoot_laser()

		# 4) wait for the animation to finish before looping
		await animated_sprite.animation_finished

func _process(delta: float) -> void:
	# Movement logic

	# World → screen using the canvas transform
	var canvas_t: Transform2D = get_viewport().get_canvas_transform()
	var screen_pos: Vector2  = canvas_t * global_position

	# Center the ProgressBar by subtracting half its width
	var bar_w: float = health_bar.size.x
	health_bar.position = screen_pos + Vector2(-bar_w * 0.5, -175)

# Called when the enemy takes damage.
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health
	if current_health == 0:
		die()
	else:
		call_deferred("update")  # redraw the health bar with the new value

func die() -> void:
	collision_shape.disabled = true
	health_bar.hide()
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	queue_free()
