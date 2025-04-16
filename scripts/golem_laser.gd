extends Area2D

var direction: Vector2 = Vector2.ZERO

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
