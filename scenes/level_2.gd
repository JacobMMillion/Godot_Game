extends Node2D
@onready var golem: CharacterBody2D = $Golem_Cont/Golem
@onready var player: CharacterBody2D = $player

func _ready():
	player.speak("I need my gun...", 3.0)
	
func end_level():
	get_tree().reload_current_scene()
	
func _on_timer_timeout() -> void:
	pass # Replace with function body.

func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_3.tscn")
