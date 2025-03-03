extends Node2D

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	anim_player.play("launch")

func _on_exit_pressed():
	get_tree().quit()
