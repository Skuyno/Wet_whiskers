extends Node

var lives: int = 1
var collected_memories := []  # Список собранных воспоминаний

signal lives_updated(lives)
signal game_over

func check_secret_ending():
	if collected_memories.size() == 5:
		get_tree().change_scene("res://SecretEnding.tscn")

func lose_life():
	lives = max(lives - 1, 0)
	emit_signal("lives_updated", lives)
	
	if lives <= 0:
		emit_signal("game_over")
		get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/menu.tscn")

func reset():
	lives = 3
	emit_signal("lives_updated", lives)
