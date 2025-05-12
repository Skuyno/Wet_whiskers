extends Area2D

@onready var cinematic_bars = $"../CinematicBars"
@onready var cat_path = $"../Path2D"
@export var spawn_points: Array[Marker2D] = []
@export var cat_path_markers: Array[Marker2D] = []

@onready var cats = [
	$"../StrayCats/CharacterBody2D",
	$"../StrayCats/CharacterBody2D2",
	$"../StrayCats/CharacterBody2D3"
]

var chase_active := false

func _on_body_entered(body):
	if body.name == "Cat" && !chase_active:
		start_chase_sequence(body)

func start_chase_sequence(player: CharacterBody2D):
	$"../../Sounds/Music".stop()
	
	chase_active = true
	player.lock_movement()
	
	cinematic_bars.animate_in()
	
	for i in cats.size():
		cats[i].global_position = spawn_points[i].global_position
		cats[i].play_approach_animation(cat_path_markers[i].global_position)
	
	await get_tree().create_timer(5.0).timeout
	
	# Старт движения
	for i in cats.size():
		cats[i].start_chasing(i * 50.0)  # Увеличиваем смещение на 50px для каждого
	
	
	cinematic_bars.animate_out()
	player.unlock_movement()
	$"../../Sounds/ChaseMusic".play()
