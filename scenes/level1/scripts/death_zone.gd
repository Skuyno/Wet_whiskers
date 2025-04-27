extends Area2D

# Called when the node enters the scene tree for the first time.
func _on_body_entered(body):
	if body.name == "Cat":
		get_tree().reload_current_scene()
		
