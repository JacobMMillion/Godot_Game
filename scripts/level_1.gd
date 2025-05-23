extends Node2D
@onready var timer = $Timer
@onready var time_label = $CanvasLayer/TimerLabel
@onready var player: CharacterBody2D = $player
@onready var GameManager = %GameManager


func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level2.tscn")

func _ready():
	GameManager.loot_label = $CanvasLayer/LootCount
	GameManager.score_label = $ScoreLabel
	GameManager.update_money_display()
	time_label.add_theme_color_override("font_color", Color.WHITE)
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()  
	time_label.text = "Time: " + str(int(timer.wait_time))
	#player.speak("Time for some shooting practice!", 3.0)

func _process(delta):
	time_label.text = "Time: " + str(int(timer.time_left))
	if timer.time_left > 0 and timer.time_left < 10:
		time_label.add_theme_color_override("font_color", Color.RED)
	else: 
		time_label.add_theme_color_override("font_color", Color.WHITE)		
func _on_Timer_timeout():
	player.die()

func end_level():
	get_tree().reload_current_scene()
	

	
