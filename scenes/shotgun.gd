extends Area2D

#— pickup state & owner ref ——
var picked_up: bool = false
var player_ref: Node = null

@export var ignore_body: Node = null

@onready var muzzle: Node2D = $Muzzle
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

#— bullet scene & parameters ——
const BULLET = preload("res://scenes/simple_bullet.tscn")
const NUM_PELLETS: int = 3
const SPREAD_DEGREES: float = 10.0   # total cone angle
const PELLET_SPEED: float = 800.0    # tweak as needed
const PELLET_DAMAGE: int   = 10       # higher than simple gun

@export var recoil_multiplier: float = 0.2    # fraction of bullet speed pushed back

#— shoot–cooldown vars —
@export var shoot_cooldown: float = 0.5  # seconds between shots
var _time_until_next_shot: float = 0.0  # counts down in _process


func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited",  Callable(self, "_on_body_exited"))

func _process(delta: float) -> void:
	if _time_until_next_shot > 0.0:
		_time_until_next_shot -= delta
		
	if not picked_up or player_ref == null or player_ref.is_dead:
		return

	
	var raw_angle = (get_global_mouse_position() - global_position).angle()
	var raw_deg = rad_to_deg(raw_angle)
	if raw_deg >= 180: raw_deg -= 360

	if get_parent().name == "GunSocketRight":
		var clamped = clamp(raw_deg, -90, 90)
		rotation = deg_to_rad(clamped)
	else:
		var pos_deg = raw_deg + 360 if raw_deg < 0 else raw_deg
		var clamped = clamp(pos_deg, 90, 270)
		rotation = deg_to_rad(clamped)

	var final_deg = rad_to_deg(rotation)
	scale.y = -1 if (final_deg > 90 and final_deg < 270) else 1

	# fire
	if Input.is_action_just_pressed("shoot") and _time_until_next_shot <= 0.0:
		_shoot()
		_time_until_next_shot = shoot_cooldown

func _shoot() -> void:
	shoot_sound.play()
	var bullet_avg_velocity = Vector2.ZERO

	# spawn pellets
	for i in range(NUM_PELLETS):
		var spread = SPREAD_DEGREES * ((i - (NUM_PELLETS - 1) / 2.0) / (NUM_PELLETS - 1))
		var pellet_rot = rotation + deg_to_rad(spread)
		var bullet = BULLET.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = muzzle.global_position
		bullet.rotation = pellet_rot

		# velocity & damage
		var vel = Vector2(cos(pellet_rot), sin(pellet_rot)) * PELLET_SPEED
		if bullet.has_method("set_velocity"):
			bullet.set_velocity(vel)
		else:
			bullet.velocity = vel
		bullet.damage = PELLET_DAMAGE

		bullet_avg_velocity += vel

	bullet_avg_velocity /= NUM_PELLETS

	# apply improved recoil
	if player_ref:
		# push back opposite muzzle direction
		var recoil = -bullet_avg_velocity * recoil_multiplier
		player_ref.velocity += recoil

# Signal callback triggered when a body enters the Area2D.
func _on_body_entered(body: Node) -> void:
	if ignore_body != null and body == ignore_body:
		return
	# Check if the colliding body is in the "Player" group.
	if body.is_in_group("Player"):
		player_ref = body
		# Call a method on the player to handle the pickup.
		# Make sure your player script has a method named "pick_up_gun" (or similar).
		body.pick_up_gun(self)
		set_collision_layer(0)
		set_collision_mask(0)

func _on_body_exited(body: Node) -> void:
	# once the ignored body leaves, allow pickup again
	if ignore_body != null and body == ignore_body:
		ignore_body = null
