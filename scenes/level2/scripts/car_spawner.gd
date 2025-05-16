extends Node2D

@export var car_scene: PackedScene
@export var spawn_interval: float = 3
@export var lane_offset: float = 50.0  # Увеличьте это значение при необходимости

func _ready():
	$Timer.start(randf_range(0.5, spawn_interval))

func _on_timer_timeout():
	var car = car_scene.instantiate()
	
	var spawn_point = $leftSpawn if randi() % 2 == 0 else $rightSpawn
	
	car.global_position = spawn_point.global_position
	
	get_tree().current_scene.add_child(car)
	
	$Timer.wait_time = randf_range(spawn_interval * 0.7, spawn_interval * 1.3)
	$Timer.start()
