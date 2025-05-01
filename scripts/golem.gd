extends CharacterBody2D

const DEFAULT_ANIM := "idle"

# ─── Idle movement tuning ─────────────────────────────────────────────────────
const BOB_SPEED        := 1.0     # cycles per second
const BOB_AMPLITUDE    := 15.0    # pixels up/down
const VERTICAL_OFFSET  := 150.0   # pixels above the player's Y
const HORIZONTAL_RANGE := 100.0   # max horizontal distance from player
const HORIZONTAL_SPEED := 45.0    # speed when correcting X

# ─── Wander tuning ───────────────────────────────────────────────────────────
const WANDER_INTERVAL_MIN := 1.5    # seconds between picking new targets
const WANDER_INTERVAL_MAX := 3.0
const WANDER_Y_RANGE      := 20.0   # pixels above/below the bob center
const WANDER_STIFFNESS_X  := 1.0    # how strongly X snaps to target
const WANDER_STIFFNESS_Y  := 0.5    # how strongly Y snaps to wander offset

# ─── Health & actions ────────────────────────────────────────────────────────
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar:       ProgressBar     = $HealthBarLayer/HealthBar
@onready var collision_shape:  CollisionShape2D = $CollisionShape2D

# direct path to player node
@onready var player: Node2D = get_node("/root/Level_3/player")

# projectile stuff
const PROJECTILE_SCENE = preload("res://scenes/golem_projectile.tscn")
@onready var muzzle_right: Node2D = $AnimatedSprite2D/ArmMuzzleR
@onready var muzzle_left: Node2D = $AnimatedSprite2D/ArmMuzzleL

# laser stuff
const LASER_SCENE = preload("res://scenes/golem_laser.tscn")
@onready var eye_right: Node2D = $AnimatedSprite2D/EyeMuzzleR
@onready var eye_left: Node2D = $AnimatedSprite2D/EyeMuzzleL

# explosions
const EXPLOSION_SCENE = preload("res://scenes/projectile_explosion.tscn")
const SMALL_EXPLOSION_SCENE = preload("res://scenes/small_explosion.tscn")
@onready var explosion_sound: AudioStreamPlayer2D = $LargeExplosion
@onready var small_explosion_sound: AudioStreamPlayer2D = $SmallExplosion

var is_defending:    bool  = false
var is_dead: 		 bool = false

var current_health:  int   = 1000
const MAX_HEALTH     := 1000

# "prepare_laser" removed
var actions = ["defend", "extend_arm"]
const MIN_DELAY := 3.0
const MAX_DELAY := 5.0

# bob timer
var bob_timer: float = 0.0
# wander state
var wander_target_x: float
var wander_target_y: float
var wander_timer:    float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	health_bar.custom_minimum_size = Vector2(150, 8)
	health_bar.min_value = 0
	health_bar.max_value = MAX_HEALTH
	health_bar.value = current_health

	# initialize wander
	wander_target_x = player.global_position.x
	wander_target_y = player.global_position.y - VERTICAL_OFFSET
	wander_timer = randf_range(WANDER_INTERVAL_MIN, WANDER_INTERVAL_MAX)

	randomize()
	_action_loop()

# ─── AI loop ──────────────────────────────────────────────────────────────────
func _action_loop() -> void:
	while true:
		# Check if already dead before doing anything.
		if is_dead:
			break

		animated_sprite.play(DEFAULT_ANIM)
		await get_tree().create_timer(randf_range(MIN_DELAY, MAX_DELAY)).timeout
		
		# Again, ensure that the enemy hasn't died during the wait.
		if is_dead:
			break
			
		var action = actions[randi() % actions.size()]
		animated_sprite.play(action)

		if action == "defend":
			is_defending = true

		if action == "extend_arm":
			# Wait until we hit frame 8
			while animated_sprite.frame != 8:
				# Always check for death in the loop
				if is_dead:
					break
				await animated_sprite.frame_changed
			
			# If died during the loop, break early.
			if is_dead:
				break

			_do_shoot_bullet()
			
		if action == "prepare_laser":
			# Wait until we hit frame 8
			while animated_sprite.frame != 13:
				# Always check for death in the loop
				if is_dead:
					break
				await animated_sprite.frame_changed
			
			# If died during the loop, break early.
			if is_dead:
				break

			_do_shoot_laser()

		# Wait for the rest of the animation to finish
		await animated_sprite.animation_finished

		# Exit if died during the animation
		if is_dead:
			break

		match action:
			"defend":
				_do_defend()
				is_defending = false

		# (we already handled extend_arm)

# ─── Movement ────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if animated_sprite.animation == DEFAULT_ANIM:
		_do_idle_movement(delta)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	var canvas_t   = get_viewport().get_canvas_transform()
	var screen_pos = canvas_t * global_position
	var bar_w      = health_bar.size.x
	health_bar.position = screen_pos + Vector2(-bar_w * 0.5, -175)

func _do_idle_movement(delta: float) -> void:
	# 1) vertical bob around (player.y - offset)
	bob_timer += delta
	var center_y = player.global_position.y - VERTICAL_OFFSET
	var desired_y = center_y + sin(bob_timer * BOB_SPEED * TAU) * BOB_AMPLITUDE
	var bob_vel = (desired_y - position.y) * 5.0

	# ─── wander timer: when it elapses, pick BOTH new X & Y targets ──────────
	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_timer = randf_range(WANDER_INTERVAL_MIN, WANDER_INTERVAL_MAX)
		wander_target_x = player.global_position.x + randf_range(-HORIZONTAL_RANGE, HORIZONTAL_RANGE)
		wander_target_y = center_y + randf_range(-WANDER_Y_RANGE, WANDER_Y_RANGE)

	# 2) move toward those wander targets
	var wander_vel_x = (wander_target_x - position.x) * WANDER_STIFFNESS_X
	var wander_vel_y = (wander_target_y - position.y) * WANDER_STIFFNESS_Y

	velocity.x = clamp(wander_vel_x, -HORIZONTAL_SPEED, HORIZONTAL_SPEED)
	velocity.y = bob_vel + wander_vel_y

	# always face the player
	animated_sprite.flip_h = (player.global_position.x < position.x)

	# disable collision when defending
	collision_shape.disabled = is_defending

# ─── Damage & death ──────────────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if is_defending:
		return
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health
	if current_health == 0:
		die()

func die() -> void:
	is_dead = true
	animated_sprite.stop()    # immediately stop the current animation
	collision_shape.disabled = true
	health_bar.hide()
	animated_sprite.play("death")
	
	# Start spawning explosions concurrently.
	# (We launch it but do not await its completion; it runs while we wait for the death animation.)
	spawn_explosions_while_dying()
	
	await animated_sprite.animation_finished
	queue_free()
	
func spawn_explosions_while_dying() -> void:
	# Continue spawning effects as long as the death animation is playing.
	while animated_sprite.is_playing() and animated_sprite.animation == "death":
		# Generate a random offset for the explosion effect in local space.
		var explosion_offset = Vector2(randf_range(-20, 20), randf_range(-15, 20))
		var explosion_global_pos = animated_sprite.to_global(explosion_offset)
		
		var explosion = EXPLOSION_SCENE.instantiate()
		explosion.scale = Vector2(0.5, 0.5)
		explosion.global_position = explosion_global_pos
		get_tree().current_scene.add_child(explosion)
		
		# Generate a different random offset for the launch effect in local space.
		var launch_offset = Vector2(randf_range(-20, 20), randf_range(-15, 20))
		var launch_global_pos = animated_sprite.to_global(launch_offset)
		
		var launch_effect = SMALL_EXPLOSION_SCENE.instantiate()
		launch_effect.scale = Vector2(0.5, 0.5)
		launch_effect.global_position = launch_global_pos
		get_tree().current_scene.add_child(launch_effect)
		
		# Play explosion sound
		explosion_sound.get_parent().remove_child(explosion_sound)
		get_tree().current_scene.add_child(explosion_sound)
		explosion_sound.pitch_scale = 0.6
		explosion_sound.play()
		
		# Play small explosion sound
		small_explosion_sound.get_parent().remove_child(small_explosion_sound)
		get_tree().current_scene.add_child(small_explosion_sound)
		small_explosion_sound.pitch_scale = 1.0
		small_explosion_sound.play()
		
		# Wait a short time before spawning the next set of effects.
		await get_tree().create_timer(0.8).timeout

# ─── Power‑move stubs ─────────────────────────────────────────────────────────
func _do_defend() -> void:
	var heal_amount = 200
	current_health = min(current_health + heal_amount, MAX_HEALTH)
	health_bar.value = current_health

func _do_shoot_bullet() -> void:
	# 1) Instance the projectile
	var b = PROJECTILE_SCENE.instantiate()
	# 2) Choose the correct muzzle based on flip_h
	var muzzle = muzzle_left if animated_sprite.flip_h else muzzle_right
	# 3) Spawn it at that muzzle
	b.global_position = muzzle.global_position
	# 4) Give it a direction based on facing
	b.direction = Vector2.LEFT  if animated_sprite.flip_h else Vector2.RIGHT
	# 5) Add it into the scene, as long as is alive
	if not is_dead:
		get_tree().current_scene.add_child(b)

func _do_shoot_laser() -> void:
	var l = LASER_SCENE.instantiate()
	var muzzle = eye_left if animated_sprite.flip_h else eye_right
	l.global_position = muzzle.global_position
	l.direction = Vector2.LEFT  if animated_sprite.flip_h else Vector2.RIGHT
	
	if not is_dead:
		get_tree().current_scene.add_child(l)
