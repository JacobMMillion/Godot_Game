extends Node2D
@onready var golem: CharacterBody2D = $Golem_Cont/Golem
@onready var player: CharacterBody2D = $player
@onready var timer = $Timer
@onready var time_label = $CanvasLayer/TimerLabel
@onready var GameManager = %GameManager


func _ready():
	GameManager.loot_label = $CanvasLayer/LootCount
	GameManager.score_label = $ScoreLabel
	time_label.add_theme_color_override("font_color", Color.WHITE)
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()  
	time_label.text = "Time: " + str(int(timer.wait_time))
	
	
func _process(delta):
	time_label.text = "Time: " + str(int(timer.time_left))
	if timer.time_left > 0 and timer.time_left < 5:
		time_label.add_theme_color_override("font_color", Color.RED)
	else: 
		time_label.add_theme_color_override("font_color", Color.WHITE)		

func _on_Timer_timeout():
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")
	
func end_level():
	get_tree().paused = true
	$GameOverUI.visible = true


func _on_button_pressed() -> void:
	var err = get_tree().change_scene_to_file("res://scenes/ending_scene.tscn")
	print("pressed → change_scene_to_file() returned: ", err)
	if err != OK:
		printerr("⚠️ Scene swap failed with error code ", err)
	else:
		print("✅ Scene change succeeded")
