extends Control

@onready var sound = $ClickSound
@onready var delay_timer = Timer.new()
@onready var player = $"../../Cat"

var pending_action: Callable = func(): pass  # Пустая заглушка
var save_path = "res://savegame.save"
func _ready():
	visible = false
	set_process_input(false)
	$AnimationPlayer.play("RESET")
	
	sound.process_mode = Node.PROCESS_MODE_ALWAYS
	
	add_child(delay_timer)
	delay_timer.one_shot = true
	delay_timer.wait_time = 0.2
	delay_timer.timeout.connect(_on_delay_timeout)

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
	pending_action = func():
		resume()
		get_tree().reload_current_scene()
	delay_timer.start()

func _on_button_2_pressed() -> void:
	sound.play()
	pending_action = func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
	delay_timer.start()

func _on_button_pressed() -> void:
	sound.play()
	pending_action = resume
	delay_timer.start()

func _on_delay_timeout():
	pending_action.call()

func _process(delta):
	testEsc()
	
func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(player.position.x)
	file.store_var(player.position.y)
	
func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	player.position.x = file.get_var(player.position.x)
	player.position.y = file.get_var(player.position.y)


func _on_button_5_pressed() -> void:
	load_game()


func _on_button_4_pressed() -> void:
	save_game()
