extends Node

var lives: int = 1
var collected_memories := []  # Список собранных воспоминаний

var player_position: Vector2
var return_scene_path = "res://scenes/level1/level1.tscn"

signal game_over

func lose_life():
	lives = max(lives - 1, 0)
	
	if lives <= 0:
		emit_signal("game_over")

func reset():
	lives = 1
