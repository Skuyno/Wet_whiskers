extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("game_over", Callable(self, "_on_end"))


func _on_end():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/menu.tscn")
