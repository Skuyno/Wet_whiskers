extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var cat_idle = $Cat_idle

func _ready() -> void:
	anim_player.play("launch")
	cat_idle.play("idle")

func _on_exit_pressed():
	get_tree().quit()
