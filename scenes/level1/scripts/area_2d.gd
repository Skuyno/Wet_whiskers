extends Area2D

func _ready():
	input_event.connect(_on_input_event)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		interact()

func interact():
	print("Взаимодействие с 2D объектом")
