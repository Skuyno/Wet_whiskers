extends Area2D

var is_cat_detected := false
var has_bread := false
var attack_timer: Timer
var shake_intensity := 0.0

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = 3.0
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_start)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print(body)
	if body.name == "Cat":
		is_cat_detected = true
		if !has_bread:
			start_attack_sequence()
	elif body.is_in_group("bread"):
		has_bread = true
		stop_attack_sequence()
		for pigeon in get_tree().get_nodes_in_group("angry pigeons"):
			pigeon.start_gathering(body.global_position)

func _on_body_exited(body):
	if body.name == "Cat":
		is_cat_detected = false
		stop_attack_sequence()
	elif body.is_in_group("bread"):
		has_bread = false
		if is_cat_detected:
			start_attack_sequence()

func start_attack_sequence():
	attack_timer.start()
	$"../Sounds/PigeonCurlikanieSound".play()
	for pigeon in get_tree().get_nodes_in_group("angry pigeons"):
		pigeon.play("nervous")

func stop_attack_sequence():
	attack_timer.stop()
	$"../Sounds/PigeonCurlikanieSound".stop()
	for pigeon in get_tree().get_nodes_in_group("angry pigeons"):
		print("nihua")
		if has_bread:
			pigeon.start_gathering(get_bread_position())
		else:
			pigeon.play("idle")

func get_bread_position() -> Vector2:
	var bread = get_tree().get_first_node_in_group("bread")
	return bread.global_position if bread else Vector2.ZERO

func _process(delta):
	var target_intensity = 1.0 if (is_cat_detected && !has_bread) else 0.0
	shake_intensity = lerp(shake_intensity, target_intensity, delta * (3.0 if is_cat_detected else 2.0))
	
	$"../Cat"/Camera2D.offset = Vector2(
		randf_range(-shake_intensity * 10, shake_intensity * 10),
		randf_range(-shake_intensity * 10, shake_intensity * 10)
	)

func _on_attack_start():
	if is_cat_detected && !has_bread:
		for pigeon in get_tree().get_nodes_in_group("angry pigeons"):
			pigeon.start_attack($"../Cat")
