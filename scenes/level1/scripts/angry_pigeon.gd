# Pigeon.gd
extends AnimatedSprite2D

enum State {IDLE, ATTACKING, GATHERING, AT_BREAD, RETURNING}
var current_state = State.IDLE
var speed = 250  # Увеличена скорость
var target: Node2D
var bread_ref: WeakRef  # Ссылка на хлеб для отслеживания
var patrol_radius = 75.0
var patrol_target: Vector2
var original_position: Vector2

func _ready():
	original_position = global_position
	play("idle")  # Начальная анимация

func start_attack(cat: Node2D):
	if current_state in [State.GATHERING, State.AT_BREAD, State.RETURNING]:
		return
	
	current_state = State.ATTACKING
	target = cat
	play("fly")  # Анимация полета
	# ... остальное из предыдущего кода

func start_gathering(bread_node: Node2D):
	if current_state == State.RETURNING:
		return
	
	bread_ref = weakref(bread_node)  # Сохраняем слабую ссылку
	current_state = State.GATHERING
	play("fly")  # Анимация полета

func return_to_original_position():
	if current_state != State.RETURNING:
		current_state = State.RETURNING
		play("fly")  # Анимация полета
		target = null

func _process(delta):
	match current_state:
		State.GATHERING:
			var bread = bread_ref.get_ref()
			if bread and is_instance_valid(bread):
				# Постоянно обновляем цель
				var target_pos = bread.global_position
				var dir = (target_pos - global_position).normalized()
				position += dir * speed * delta
				flip_h = dir.x < 0
				
				# Переход к патрулированию при приближении
				if global_position.distance_to(target_pos) < 15:
					current_state = State.AT_BREAD
					generate_new_patrol_target()
			else:
				return_to_original_position()
		
		State.AT_BREAD:
			var bread = bread_ref.get_ref()
			if bread and is_instance_valid(bread):
				# Обновляем базовую позицию
				var bread_pos = bread.global_position
				var dir = (patrol_target - global_position).normalized()
				position += dir * speed * 0.5 * delta  # Медленное патрулирование
				flip_h = dir.x < 0
				
				if global_position.distance_to(patrol_target) < 10:
					generate_new_patrol_target()
			else:
				return_to_original_position()
		
		State.RETURNING:
			var dir = (original_position - global_position).normalized()
			position += dir * speed * 0.7 * delta  # Быстрый возврат
			flip_h = dir.x < 0
			
			if global_position.distance_to(original_position) < 5:
				current_state = State.IDLE
				global_position = original_position
				play("idle")  # Анимация покоя
		
		State.ATTACKING:
			if target and is_instance_valid(target):
				# Преследование кота
				var dir = (target.global_position - global_position).normalized()
				position += dir * speed * delta
				flip_h = dir.x < 0
				
				# Проверка дистанции для атаки
				if global_position.distance_to(target.global_position) < 20:
					Global.lose_life()
			else:
				return_to_original_position()

func generate_new_patrol_target():
	var bread = bread_ref.get_ref()
	if bread and is_instance_valid(bread):
		var angle = randf_range(-PI/4, PI/4)  # Небольшой разброс по вертикали
		var offset = Vector2(
			randf_range(-patrol_radius, patrol_radius),
			sin(angle) * patrol_radius * 0.3
		)
		patrol_target = bread.global_position + offset
