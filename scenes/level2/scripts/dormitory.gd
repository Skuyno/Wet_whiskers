extends Node2D

@export var item_scenes: Array[PackedScene]
@onready var spawn_points = $SpawnPoints.get_children()
@onready var timer = $Timer

func _ready():
	timer.start()


func _on_timer_timeout():
	spawn_random_item()
	timer.wait_time = randf_range(0, 1)
	timer.start()

func spawn_random_item():
	var scene = item_scenes[randi() % item_scenes.size()]
	var item = scene.instantiate()
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	item.global_position = spawn_point.global_position
	add_child(item)
