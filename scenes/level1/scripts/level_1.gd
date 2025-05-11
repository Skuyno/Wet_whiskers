# Level.gd
extends Node2D
@onready var anim_player: AnimationPlayer = $Launching/AnimationPlayer
var save_path = "res://savegame.save"
@onready var player = $Cat

func _ready():
	#anim_player.play("fade_in")
	Global.game_over.connect(show_death_screen)
	load_game()
	

func show_death_screen():
	var death_screen = preload("res://scenes/death_screen_menu/death_screen.tscn").instantiate()
	
	add_child(death_screen)
	
func load_game():
	pass
	var file = FileAccess.open(save_path, FileAccess.READ)
	player.position.x = file.get_var(player.position.x)
	player.position.y = file.get_var(player.position.y)
