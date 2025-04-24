extends Button

@onready var anim = $AnimatedSprite2D  
@onready var sound = $"../Sounds/ClickSound"

func _ready():
	anim.play("idle")  

func _on_mouse_entered():
	anim.play("hover")  

func _on_mouse_exited():
	anim.play("idle")  

func _on_pressed():
	sound.play()
	anim.play("pressed")
	await get_tree().create_timer(0.3).timeout  # Даем звуку проиграться
	get_tree().change_scene_to_file("res://scenes/prologue/prologue.tscn")

func _on_button_up():
	anim.play("aimed")  

func _on_button_down():
	anim.play("pressed")
