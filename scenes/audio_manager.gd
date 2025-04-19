extends Node2D

@onready var world_music: AudioStreamPlayer2D = $WorldMusic
@onready var golem_fight_music: AudioStreamPlayer2D = $GolemFightMusic


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
