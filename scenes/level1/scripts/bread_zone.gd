extends Area2D

# Добавляем экспорт переменной для зоны хлеба
@export var bread_zone: Area2D

var is_cat_detected = false
var attack_timer: Timer
var shake_intensity: float = 0.0

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = 3.0
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_start)
	
	# Связываем сигналы зоны хлеба
	bread_zone.body_entered.connect(_on_bread_entered)
	bread_zone.body_exited.connect(_on_bread_exited)

func _on_body_entered(body):
	if body.name == "Cat" && !bread_zone.has_bread():
		start_cat_detection()

func _on_body_exited(body):
	if body.name == "Cat":
		stop_cat_detection()

func start_cat_detection():
	is_cat_detected = true
	attack_timer.start()
	$"../Sounds/PidgeonCurlikanieSound".play()
	update_pigeons_state()

func stop_cat_detection():
	is_cat_detected = false
	attack_timer.stop()
	$"../Sounds/PidgeonCurlikanieSound".stop()
	update_pigeons_state()

func _process(delta):
	# Обновляем дрожание только при атаке на кота
	if is_cat_detected && !bread_zone.has_bread():
		shake_intensity = min(shake_intensity + delta / 3.0, 1.0)
	else:
		shake_intensity = max(shake_intensity - delta * 2.0, 0.0)
	
	$"../Cat/Camera2D".offset = Vector2(
		randf_range(-shake_intensity * 10, shake_intensity * 10),
		randf_range(-shake_intensity * 10, shake_intensity * 10)
	)

func _on_attack_start():
	if is_cat_detected && !bread_zone.has_bread():
		for pigeon in get_tree().get_nodes_in_group("pigeons"):
			pigeon.start_attack($"../Cat")

func update_pigeons_state():
	for pigeon in get_tree().get_nodes_in_group("pigeons"):
		if bread_zone.has_bread():
			pigeon.start_gathering(bread_zone.global_position)
		else:
			pigeon.return_to_idle()

# Обработчики для зоны хлеба
func _on_bread_entered(body):
	if body.is_in_group("bread"):
		stop_cat_detection()
		update_pigeons_state()

func _on_bread_exited(body):
	if body.is_in_group("bread"):
		update_pigeons_state()
