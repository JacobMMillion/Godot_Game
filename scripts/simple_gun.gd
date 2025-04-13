extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the "body_entered" signal to detect the player colliding with the gun.
	connect("body_entered", Callable(self, "_on_body_entered"))

# Called every frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

# Signal callback triggered when a body enters the Area2D.
func _on_body_entered(body: Node) -> void:
	
	# Check if the colliding body is in the "Player" group.
	if body.is_in_group("Player"):
		
		# Call a method on the player to handle the pickup.
		# Make sure your player script has a method named "pick_up_gun" (or similar).
		body.pick_up_gun(self)
		set_collision_layer(0)
		set_collision_mask(0)
