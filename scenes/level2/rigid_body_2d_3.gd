extends RigidBody2D

func _ready():
	# Автоматическая настройка детектора
	if not has_node("VisibleOnScreenNotifier2D"):
		var notifier = VisibleOnScreenNotifier2D.new()
		notifier.rect = Rect2(-40, -40, 80, 80)
		add_child(notifier)
		notifier.screen_exited.connect(_reset)
	
	# Принудительная синхронизация
	freeze = true
	visible = false
	print(name, " инициализирован")

func _reset():
	freeze = true
	visible = false
	global_position = Vector2(-1000, -1000)
	print(name, " сброшен")
