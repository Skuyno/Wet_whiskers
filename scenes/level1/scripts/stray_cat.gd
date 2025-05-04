extends CharacterBody2D

@export var base_speed: float = 80
@export var jump_force: float = 300.0
@export var path_events: Array[Dictionary] = [
	{"position": 300, "action": "jump", "value": null},
	{"position": 300, "action": "speed", "value": 200},
	{"position": 420, "action": "run", "value": null},
	{"position": 420, "action": "speed", "value": 80},
	{"position": 600, "action": "jump", "value": null},
	{"position": 600, "action": "speed", "value": 200},
	{"position": 650, "action": "run", "value": null},
	{"position": 650, "action": "speed", "value": 80},
	{"position": 800, "action": "climb", "value": null},
	{"position": 890, "action": "run", "value": null},
	{"position": 980, "action": "jump", "value": null},
	{"position": 980, "action": "speed", "value": 200},
	{"position": 1120, "action": "run", "value": null},
	{"position": 1120, "action": "speed", "value": 80},
	{"position": 1350, "action": "jump", "value": null},
	{"position": 1350, "action": "speed", "value": 200},
	{"position": 1400, "action": "run", "value": null},
	{"position": 1400, "action": "speed", "value": 80},
]

@onready var path = $"../../Path2D"
@onready var sprite = $Sprite
var path_follow: PathFollow2D
var is_chasing = false
var current_speed: float = 80
var next_event_index: int = 0

func start_chasing(initial_offset: float):
	current_speed = base_speed
	next_event_index = 0
	
	if path:
		# Удаляем старый PathFollow2D если существует
		if is_instance_valid(path_follow) && path_follow.is_inside_tree():
			path.remove_child(path_follow)
		
		# Создаем новый PathFollow2D
		path_follow = PathFollow2D.new()
		path.add_child(path_follow)
		path_follow.progress = initial_offset
		global_position = path_follow.global_position
	
	is_chasing = true
	sprite.play("run")

func _physics_process(delta):
	if is_chasing && is_instance_valid(path_follow):
		# Обновляем прогресс с текущей скоростью
		path_follow.progress += current_speed * delta
		global_position = path_follow.global_position
		
		# Проверяем события пути
		check_path_events(path_follow.progress)
		
		# Проверка достижения игрока
		if global_position.x >= $"../../../Cat".global_position.x:
			Global.lose_life()

func check_path_events(current_position: float):
	while next_event_index < path_events.size() && current_position >= path_events[next_event_index]["position"]:
		handle_event(path_events[next_event_index])
		next_event_index += 1

func handle_event(event: Dictionary):
	match event["action"]:
		"jump":
			perform_jump()
		"speed":
			current_speed = event["value"]
		"climb":
			perform_climb()
		"run":
			perform_run()

func perform_run():
	sprite.play("run")

func perform_climb():
	sprite.play("climb")

func perform_jump():
	sprite.play("jump")

func play_approach_animation(target_pos: Vector2):
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 1.5)
	await tween.finished
	sprite.play("hiss")
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	$Meow.play()
