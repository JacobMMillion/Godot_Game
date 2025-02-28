extends Node

@onready var score_label: Label = $ScoreLabel

var money = 0

func add_money():
	money += 1
	score_label.text = "Money: " + str(money)
