extends CanvasLayer

@onready var anim_player = $AnimationPlayer
@onready var dead_cat_sprite = $DeadCatSprite
@onready var buttons_container = $ButtonsContainer2
@onready var delay_timer = $DelayTimer
var save_path = "res://savegame.save"
@onready var player = $Cat

func _ready():
	$AudioStreamPlayer.play()
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	dead_cat_sprite.modulate.a = 0
	anim_player.play("cat_fade_in")
	
	buttons_container.hide()
	delay_timer.start()
	
	get_tree().paused = true

func _on_delay_timer_timeout():
	buttons_container.show()

func _on_restart_button_pressed():
	get_tree().paused = false
	Global.reset()
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")


func _on_load_pressed() -> void:
	get_tree().paused = false
	Global.reset()
	# Эмитируем сигнал или вызываем метод загрузки в сцене уровня
	get_tree().current_scene.load_game()
	queue_free() # Удаляем экран смерти
	
