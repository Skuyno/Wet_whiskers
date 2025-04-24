extends OptionButton


@onready var window_mode_option = $OptionButton
@onready var anim = $AnimatedSprite2D
@onready var sound = $"../../Sounds/ClickSound"

func _ready():
	anim.play("idle")  # Запускаем анимацию ожидания

# Когда курсор наводится на кнопку
func _on_mouse_entered():
	anim.play("hover")  

# Когда курсор уходит с кнопки
func _on_mouse_exited():
	anim.play("idle")  

# Когда кнопка нажата
func _on_pressed():
	sound.play()
	anim.play("pressed")  

# Когда кнопка отпущена
func _on_button_up():
	anim.play("aimed")
	
func _on_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
