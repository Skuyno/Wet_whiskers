# UI.gd
extends CanvasLayer

@onready var hearts = $HeartsContainer.get_children()

func _ready():
	Global.connect("lives_updated", Callable(self, "_update_hearts"))
	_update_hearts(Global.lives)

func _update_hearts(new_lives: int):
	for i in range(hearts.size()):
		if i < new_lives:
			hearts[i].texture = preload("res://assets/sprites/Heart_full.png")
		else:
			hearts[i].texture = preload("res://assets/sprites/Heart_empty.png")
