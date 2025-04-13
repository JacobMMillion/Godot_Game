extends Area2D

var picked_up: bool = false
const BULLET = preload("res://scenes/simple_bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the "body_entered" signal to detect the player colliding with the gun.
	connect("body_entered", Callable(self, "_on_body_entered"))

# Called every frame.
func _process(delta: float) -> void:
	if picked_up:
		# Compute the raw angle from the gun to the mouse.
		var raw_angle: float = (get_global_mouse_position() - global_position).angle()
		# Convert to degrees for easier clamping.
		var raw_deg: float = rad_to_deg(raw_angle)
		
		# Normalize raw_deg to the range [-180, 180)
		if raw_deg >= 180:
			raw_deg -= 360

		# Determine allowed angle range based on the parent's name.
		# (Assumes the parent's name is either "GunSocketRight" or "GunSocketLeft")
		if get_parent().name == "GunSocketRight":
			# When on the right socket, allow aiming only between -90° and +90°.
			var clamped_deg: float = clamp(raw_deg, -90, 90)
			rotation = deg_to_rad(clamped_deg)
		else:
			# When on the left socket, allow aiming only between 90° and 270°.
			# If raw_deg is negative, add 360 to work with a 0 to 360 range.
			var pos_deg: float = raw_deg
			if pos_deg < 0:
				pos_deg += 360
			var clamped_deg: float = clamp(pos_deg, 90, 270)
			rotation = deg_to_rad(clamped_deg)
		
		# Now, mirror the sprite based on the final rotation angle.
		# Calculate the final angle in degrees.
		var final_deg: float = rad_to_deg(rotation)
		# Use the same rule as before:
		# If the angle is between 90° and 270°, flip the y-scale.
		if final_deg > 90 and final_deg < 270:
			scale.y = -1
		else:
			scale.y = 1
			
			
		# SHOOTING
		if Input.is_action_just_pressed("shoot"):
				var bullet_instance = BULLET.instantiate()
				get_tree().root.add_child(bullet_instance)
				bullet_instance.global_position = global_position
				bullet_instance.rotation = rotation


# Signal callback triggered when a body enters the Area2D.
func _on_body_entered(body: Node) -> void:
	
	# Check if the colliding body is in the "Player" group.
	if body.is_in_group("Player"):
		
		# Call a method on the player to handle the pickup.
		# Make sure your player script has a method named "pick_up_gun" (or similar).
		body.pick_up_gun(self)
		set_collision_layer(0)
		set_collision_mask(0)
