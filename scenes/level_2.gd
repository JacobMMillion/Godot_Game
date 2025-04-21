extends Node2D
@onready var timer = $Timer
@onready var time_label = $CanvasLayer/TimerLabel2

func _ready():
	timer.start()  
	time_label.text = "Time: " + str(int(timer.wait_time))
	#AudioManager.golem_fight_music.play()

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
