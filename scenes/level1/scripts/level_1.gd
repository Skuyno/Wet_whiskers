# Level.gd
extends Node2D

func _ready():
	Global.game_over.connect(show_death_screen)

func show_death_screen():
	var death_screen = preload("res://scenes/death_screen_menu/death_screen.tscn").instantiate()
	add_child(death_screen)
