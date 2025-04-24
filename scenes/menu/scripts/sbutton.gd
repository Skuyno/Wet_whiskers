extends Button


@onready var anim = $AnimatedSprite2D  # Получаем ссылку на анимацию
@onready var sound = $"../Sounds/ClickSound"

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
	get_tree().change_scene_to_file("res://scenes/prologue/prologue.tscn")

# Когда кнопка отпущена
func _on_button_up():
	anim.play("aimed")  # Возвращаемся к анимации наведения
	
func _on_button_down():
	anim.play("pressed")
	
