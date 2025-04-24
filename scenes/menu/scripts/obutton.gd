extends Button

@onready var anim = $AnimatedSprite2D
@onready var options_menu = $"../OptionsMenu" # Путь до окна настроек (подстрой под своё дерево)

func _ready():
	anim.play("idle")
	options_menu.visible = false

func _on_mouse_entered():
	anim.play("hover")

func _on_mouse_exited():
	anim.play("idle")

func _on_pressed():
	anim.play("pressed")
	options_menu.visible = true

func _on_button_up():
	anim.play("aimed")

func _on_button_down():
	anim.play("pressed")
