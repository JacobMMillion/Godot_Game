extends Node

@onready var score_label: Label = $ScoreLabel
@onready var loot: Label = get_node("/root/level1/CanvasLayer/LootCount")


var money = 0

func _ready():
	pass
	
func add_money():
	money += 1
	loot.text  = "Loot: " + str(money)
	score_label.text = "Coins: " + str(money)
