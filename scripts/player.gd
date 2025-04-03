extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0  # Speed during roll
const GRAVITY = 980  # Define gravity constant

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# New variables for rolling
var is_rolling: bool = false
var roll_direction: float = 1.0
var roll_timer: float = 0.0
const ROLL_DURATION: float = 0.5  # Roll lasts 0.5 seconds

func _physics_process(delta: float) -> void:
	# Handle roll timer
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0:
			is_rolling = false
		
		# Move faster in roll direction
		velocity.x = roll_direction * ROLL_SPEED
		animated_sprite.play("roll")
		
		# Check for collisions with slimes during roll
		check_slime_collisions()
		
		move_and_slide()
		return  # Skip normal movement during roll
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle roll
	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		start_roll()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	# flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# play animations
	if is_on_floor():		
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func start_roll() -> void:
	is_rolling = true
	roll_timer = ROLL_DURATION
	
	# Set roll direction based on sprite direction
	roll_direction = -1.0 if animated_sprite.flip_h else 1.0
	
	# Start roll animation
	animated_sprite.play("roll")

func check_slime_collisions() -> void:
	
	# Get all collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if we collided with a slime
		if collider.is_in_group("slimes"):
			print("KILLING SLIME: ", collider.name)
			# Kill the slime
			collider.queue_free()

# Public method to check if player is rolling
func is_player_rolling() -> bool:
	return is_rolling
