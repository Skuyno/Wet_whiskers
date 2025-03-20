extends Button


@onready var anim = $AnimatedSprite2D  # Получаем ссылку на анимацию

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
	anim.play("pressed")  

# Когда кнопка отпущена
func _on_button_up():
	anim.play("aimed")  # Возвращаемся к анимации наведения
	
func _on_button_down():
	anim.play("pressed")
