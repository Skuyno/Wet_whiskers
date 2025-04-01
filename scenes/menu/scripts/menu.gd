extends Node2D

@onready var anim_player = $Launching/AnimationPlayer
@onready var cat_idle = $Cat_idle

func _ready() -> void:
	cat_idle.play("idle")
