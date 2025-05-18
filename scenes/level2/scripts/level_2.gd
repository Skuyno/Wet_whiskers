extends Node2D
@onready var anim_player: AnimationPlayer = $Launching/AnimationPlayer
var save_path = "res://savegame.save"
@onready var player = $Cat

func _ready():
	$Sounds/Music.play()
	Global.game_over.connect(show_death_screen)
	$Cat.enter_lock_state()
	await get_tree().create_timer(1.0).timeout
	$Cat.exit_lock_state()
	

func show_death_screen():
	var death_screen = preload("res://scenes/death_screen_menu/death_screen.tscn").instantiate()
	
	add_child(death_screen)
	
func load_game():

	var file = FileAccess.open(save_path, FileAccess.READ)
	player.position.x = file.get_var(player.position.x)
	player.position.y = file.get_var(player.position.y)
	


func _on_timer_timeout() -> void:
	pass # Replace with function body.
