extends Node2D
@onready var timer = $Timer
@onready var time_label = $CanvasLayer/TimerLabel
@onready var player: CharacterBody2D = $player

func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level2.tscn")

func _ready():
	timer.start()  
	time_label.text = "Time: " + str(int(timer.wait_time))
	player.speak("Time for some shooting practice!", 3.0)
	

func _process(delta):
	time_label.text = "Time: " + str(int(timer.time_left))
	if timer.time_left < 11:
		time_label.add_theme_color_override("font_color", Color.RED)
	
func _on_Timer_timeout():
	print("Time's up! Level Over!")
	end_level()

func end_level():
	get_tree().reload_current_scene()
	
func _on_timer_timeout() -> void:
	pass # Replace with function body.
