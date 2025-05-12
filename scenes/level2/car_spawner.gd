extends Node2D

@export var car_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var lane_offset: float = 50.0  # Увеличьте это значение при необходимости

func _ready():
	$Timer.start(randf_range(0.5, spawn_interval))

func _on_timer_timeout():
	var car = car_scene.instantiate()
	
	# Используем глобальные координаты спавнера
	var spawn_position = global_position
	var lane = 1 if randi() % 2 == 0 else -1
	spawn_position.x += lane * lane_offset
	spawn_position.y = global_position.y
	
	# Устанавливаем глобальную позицию машине
	car.global_position = spawn_position
	
	add_child(car)
	$Timer.wait_time = randf_range(spawn_interval * 0.7, spawn_interval * 1.3)
	$Timer.start()
