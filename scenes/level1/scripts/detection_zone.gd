extends Area2D

var is_cat_detected = false
var attack_timer: Timer
var shake_intensity: float = 0.0

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = 3.0
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_on_attack_start"))

func _on_body_entered(body):
	if body.name == "Cat":
		is_cat_detected = true
		attack_timer.start()
		$"../Sounds/PigeonCurlikanieSound".play()
		for pigeon in get_tree().get_nodes_in_group("pigeons"):
			pigeon.play("nervous")
			
func _process(delta):
	var target_intensity = 1.0 if (is_cat_detected) else 0.0
	shake_intensity = lerp(shake_intensity, target_intensity, delta * 3.0)
	
	$"../Cat"/Camera2D.add_shake(shake_intensity/8)

func _on_body_exited(body):
	if body.name == "Cat":
		is_cat_detected = false
		attack_timer.stop()
		for pigeon in get_tree().get_nodes_in_group("pigeons"):
			pigeon.play("idle")
		$"../Sounds/PigeonCurlikanieSound".stop()

func _on_attack_start():
	if is_cat_detected:
		# Взлёт голубей с фона
		for pigeon in get_tree().get_nodes_in_group("pigeons"):
			pigeon.take_off()
