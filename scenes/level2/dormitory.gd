extends Node2D

@export var spawn_delay: float = 1.5
@export var initial_force: float = 80.0

@onready var items_parent = $"/root/Level2/Items"

func _ready():
	print("Старт системы. Предметов: ", items_parent.get_child_count())
	$Timer.start(spawn_delay)

func _on_timer_timeout():
	var available_items = items_parent.get_children().filter(
		func(item): return item is RigidBody2D and item.freeze
	)
	
	if available_items.is_empty():
		print("Нет доступных предметов")
		return
	
	var item = available_items[0] as RigidBody2D
	var spawn_point = $SpawnPoints.get_children().pick_random()
	
	# Критически важные настройки:
	item.global_position = spawn_point.global_position
	item.visible = true
	item.freeze = false
	item.sleeping = false
	
	# Сильный импульс вниз + случайное отклонение
	item.apply_central_impulse(Vector2(
		randf_range(-initial_force, initial_force),
		randf_range(100, 200)  # Обязательно сильный толчок вниз!
	))
	
	print("Активирован: ", item.name, " на ", spawn_point.global_position)
	$Timer.start(spawn_delay)
