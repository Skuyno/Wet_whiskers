extends Control

@onready var sound = $ClickSound

func _ready():
	visible = false
	set_process_input(false)
	$AnimationPlayer.play("RESET")

func pause():
	visible = true
	set_process_input(true)
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func resume():
	get_tree().paused = false
	visible = false
	set_process_input(false)
	$AnimationPlayer.play_backwards("blur")
	
func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()

func _on_button_3_pressed() -> void:
	sound.play()
	resume()
	get_tree().reload_current_scene()


func _on_button_2_pressed() -> void:
	sound.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")


func _on_button_pressed() -> void:
	sound.play()
	resume()

func _process(delta):
	testEsc()
