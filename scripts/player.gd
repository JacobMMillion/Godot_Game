extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0  # Speed during roll
const GRAVITY = 980       # Define gravity constant

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# New variables for rolling
var is_rolling: bool = false
var roll_direction: float = 1.0
var roll_timer: float = 0.0
const ROLL_DURATION: float = 0.5  # Roll lasts 0.5 seconds

# Reference to the currently equipped gun, if any.
var equipped_gun: Node = null

func _physics_process(delta: float) -> void:
	# Handle roll timer.
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0:
			is_rolling = false
		
		velocity.x = roll_direction * ROLL_SPEED
		animated_sprite.play("roll")
		check_slime_collisions()
		move_and_slide()
		return  # Skip normal movement during roll
	
	# Apply gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle roll.
	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		start_roll()

	# Get the input direction and handle movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Update facing direction and flip the sprite accordingly.
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animations.
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
	
	# Continuously update the gun's socket if a gun is equipped.
	update_gun_socket()

func start_roll() -> void:
	is_rolling = true
	roll_timer = ROLL_DURATION
	roll_direction = -1.0 if animated_sprite.flip_h else 1.0
	animated_sprite.play("roll")

func check_slime_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("slimes"):
			print("KILLING SLIME: ", collider.name)
			collider.queue_free()

func is_player_rolling() -> bool:
	return is_rolling

# Called by the gun when the player overlaps it.
func pick_up_gun(gun: Node) -> void:
	var socket_node: Node
	# Choose the socket based on the current facing direction.
	if animated_sprite.flip_h == true:
		socket_node = $GunSocketLeft
	else:
		socket_node = $GunSocketRight

	# Remove the gun from its current parent (if any).
	if gun.get_parent():
		gun.get_parent().remove_child(gun)

	# Attach the gun to the chosen socket.
	socket_node.add_child(gun)
	# Set the gun's local position to zero so that it sits at the socket's origin.
	gun.position = Vector2.ZERO
	gun.show()
	
	# Remember the equipped gun for continuous socket updating.
	equipped_gun = gun

# Called every frame to check if the gun should be reparented.
func update_gun_socket() -> void:
	if equipped_gun:
		var desired_socket: Node
		if animated_sprite.flip_h == true:
			desired_socket = $GunSocketLeft
		else:
			desired_socket = $GunSocketRight
		
		# If the gun's current parent isn't the desired socket, reparent it.
		if equipped_gun.get_parent() != desired_socket:
			equipped_gun.get_parent().remove_child(equipped_gun)
			desired_socket.add_child(equipped_gun)
			equipped_gun.position = Vector2.ZERO
