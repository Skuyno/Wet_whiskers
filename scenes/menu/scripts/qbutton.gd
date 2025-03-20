extends Button


@onready var anim = $AnimatedSprite2D  

func _ready():
	anim.play("idle")  

func _on_mouse_entered():
	anim.play("hover")  

func _on_mouse_exited():
	anim.play("idle")  
	
func _on_pressed():
	anim.play("pressed")  
	await anim.animation_finished  
	get_tree().quit()  

func _on_button_up():
	anim.play("aimed")  
	
func _on_button_down():
	anim.play("pressed")
	
