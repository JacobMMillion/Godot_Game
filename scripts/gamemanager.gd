extends Node

var loot_label: Label = null
var score_label: Label = null


func _ready():
	pass
	
func add_money():
	Global.score += 1
	if loot_label:
		loot_label.text = "Loot Count: " + str(Global.score)
	if score_label:
		score_label.text = "Coins: " + str(Global.score)
		
func update_money_display():
	if loot_label:
		loot_label.text = "Loot Count: " + str(Global.score)
	if score_label:
		score_label.text = "Coins: " + str(Global.score)
