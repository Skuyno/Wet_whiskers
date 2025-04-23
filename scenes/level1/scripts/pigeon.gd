extends AnimatedSprite2D

# Настройки
var speed = 300
var damage = 1
var direction = Vector2.RIGHT
var cat: Node2D
var is_flying = false  # Флаг для отслеживания состояния полёта
var attack_timer: Timer

func take_off():
	attack_timer = Timer.new()
	attack_timer.name = "AttackTimer"
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	$"../../Sounds/PidgeonAttackSound".play()
	
	cat = $"../../Cat"
	if !cat:
		queue_free()
		return
	
	# Направление к коту
	direction = (cat.global_position - global_position).normalized()
	if direction.x < 0:
		flip_h = true
	
	# Переключаемся на полёт
	#play("fly")
	is_flying = true
	attack_timer.start(3.0)

func _process(delta):
	if is_flying:
		fly_process(delta)

func fly_process(delta):
	direction = (cat.global_position - global_position).normalized()
	position += direction * speed * delta
	
	if cat:
		var distance_to_cat = global_position.distance_to(cat.global_position)
		if distance_to_cat < 20:
			Global.lose_life()

func _on_AttackTimer_timeout():
	queue_free()
