extends Area2D

# Called when the node enters the scene tree for the first time.
func _on_body_entered(body):
	if body.name == "Cat":
		await get_tree().create_timer(1).timeout
		Global.lose_life()
		
		
