extends Area2D

@onready var golem: CharacterBody2D = $"../Golem_Cont/Golem"
@onready var label: Label = $Label
@onready var level_3_button: Button = $"../Level3_Button"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	level_3_button.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if golem and is_instance_valid(golem) and !golem.is_dead:
		label.text = "The Golem \nstill lives..."
		label.visible = true	
	else:
		label.text = "Golem felled!"
		label.visible = true
		level_3_button.visible = true
		# Level passed! Load level 3 or do sth else...


func _on_body_exited(body: Node2D) -> void:
	label.visible = false
