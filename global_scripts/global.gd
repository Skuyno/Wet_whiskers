extends Node

var lives: int = 3

signal lives_updated(lives)
signal game_over

func lose_life():
	lives = max(lives - 1, 0)
	emit_signal("lives_updated", lives)
	
	if lives <= 0:
		emit_signal("game_over")

func reset():
	lives = 3
	emit_signal("lives_updated", lives)
