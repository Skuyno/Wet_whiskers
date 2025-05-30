extends Area2D

# Called when the node enters the scene tree for the first time.
func _on_body_entered(body):
	if body.name == "Cat":
		$"../Sounds/Music".stop()
		Global.lose_life()
		
		
		
