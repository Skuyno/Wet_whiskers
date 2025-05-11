extends CharacterBody2D

# Настройки движения
const WALK_SPEED = 70.0
const RUN_SPEED = 120.0
const CROUCH_SPEED = 50.0
const JUMP_FORCE = -200.0
const CLIMB_SPEED = 60.0
const GRAVITY = 980.0
const INVINCIBILITY_DURATION = 1.5
const DAMAGE_KNOCKBACK = Vector2(200, -150)

# Состояния персонажа
enum State {
	NORMAL,
	CROUCHING,
	CLIMBING,
	MEOW,
	LICK,
	DAMAGED,
	INTERACTION,
	DEAD
}

# Экспортируемые переменные
@export var current_state: State = State.NORMAL
@onready var sprite = $CatSprite
@onready var climb_detector = $ClimbArea
@onready var carry_position = $CarryPosition  # Маркер позиции в зубах
@onready var item_parent = get_tree().current_scene

# Системные переменные
var is_climbing_possible = false
var can_exit_climb = false
var exit_delay = 0.2
var exit_timer = 0.2
var climb_target: Node2D = null
var climb_facing_right: bool = true
var ignore_climb_until_exit = false
var entered_climb_areas = []
var is_invincible = false
var invincibility_timer: Timer
var carried_item: RigidBody2D = null
var original_item_collision_layer: int
var original_item_parent: Node

func _ready():
	# Инициализация таймера неуязвимости
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	add_child(invincibility_timer)
	invincibility_timer.timeout.connect(_end_invincibility)
	
	# Настройка соединений сигналов
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	$ClimbArea.area_entered.connect(_on_climb_area_entered)
	$ClimbArea.area_exited.connect(_on_climb_area_exited)
	add_to_group("player")

func _physics_process(delta):
	# Обработка состояний
	match current_state:
		State.NORMAL:
			handle_normal_state(delta)
		State.CROUCHING:
			handle_crouch_state(delta)
		State.CLIMBING:
			handle_climb_state(delta)
		State.MEOW, State.LICK:
			handle_special_animations()
		State.DAMAGED:
			handle_damaged_state(global_position)
		State.INTERACTION:
			handle_interaction_state()
	
	# Применяем движение
	move_and_slide()
	
	# Обновляем анимации
	update_animations()

func handle_normal_state(delta):
	# Гравитация
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	# Подбор предметов
	if Input.is_action_just_pressed("interact"):
		enter_interaction_state()
	
	# Учёт возможности бегать
	var target_speed = WALK_SPEED
	if Input.is_action_pressed("sprint"):
		target_speed = RUN_SPEED
		
	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
	
	# Горизонтальное движение
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * target_speed
	
	# Приседание
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		enter_crouch_state()
	elif current_state == State.CROUCHING and not Input.is_action_pressed("ui_down"):
		exit_crouch_state()
	
	# Лазание
	if is_climbing_possible and not ignore_climb_until_exit:
		enter_climb_state()
	
	# Специальные действия
	if Input.is_action_just_pressed("meow"):
		start_meow()
	elif Input.is_action_just_pressed("lick"):
		start_lick()

func handle_crouch_state(_delta):
	# Движение вприсядку
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * CROUCH_SPEED
	
	# Выход из приседания	
	if Input.is_action_just_released("ui_down"):
		exit_crouch_state()

func handle_climb_state(delta):
	# Вертикальное движение
	var vertical = Input.get_axis("ui_up", "ui_down")
	velocity = Vector2(0, vertical * CLIMB_SPEED)
	
	# Обновляем направление относительно объекта
	update_climb_facing()
	
	# Обработка выхода через спрыгивание
	var horizontal = Input.get_axis("ui_left", "ui_right")
	if horizontal != 0 and can_exit_climb:
		# Устанавливаем направление прыжка
		velocity = Vector2(
			horizontal * WALK_SPEED * 1.2, 
			JUMP_FORCE * 0.8
		)
		sprite.flip_h = horizontal < 0
		exit_climb_state(true)
		can_exit_climb = false
		exit_timer = exit_delay
		return
	
	# Таймер задержки для спрыгивания
	if not can_exit_climb:
		exit_timer -= delta
		if exit_timer <= 0:
			can_exit_climb = true
	
	# Выход при нажатии вверх
	if Input.is_action_pressed("ui_up") and not is_climbing_possible:
		velocity.y = JUMP_FORCE * 1.25
		exit_climb_state(true)
		can_exit_climb = false
		exit_timer = exit_delay
		return
	
	# Автоматический выход если нет доступных зон
	if entered_climb_areas.is_empty():
		exit_climb_state(false)
		can_exit_climb = false
		exit_timer = exit_delay
		return
	
	# Плавный выход при покидании зоны
	if not is_climbing_possible:
		exit_climb_state(false)

func handle_special_animations():
	# Блокируем движение во время специальных анимаций
	velocity = Vector2.ZERO

func update_animations():
	if current_state == State.DEAD:
		return
	
	if current_state == State.MEOW or current_state == State.LICK:
		return  # Не прерываем специальные анимации
	
	match current_state:
		State.NORMAL:
			if not is_on_floor():
				sprite.play("jump" if velocity.y < 0 else "fall")
			else:
				if abs(velocity.x) > 0:
					if Input.is_action_pressed("sprint"):
						sprite.play("run")
					else:
						sprite.play("walk")
				else:
					sprite.play("idle")
		
		State.CROUCHING:
			if abs(velocity.x) > 0:
				sprite.play("crouch_walk")
			elif(sprite.animation != "crouch_start" or not sprite.is_playing()):
				sprite.play("crouch_start")
		
		State.CLIMBING:
			sprite.play("climb_up" if abs(velocity.y) > 0 else "climb_idle")
	
	# Отражаем спрайт
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	
	if carried_item:
		var item_sprite = carried_item.get_node("Sprite2D")
		item_sprite.flip_h = sprite.flip_h
		
		# Корректируем позицию относительно направления
		if sprite.flip_h:
			carried_item.position = Vector2(-carry_position.position.x, carry_position.position.y)
		else:
			carried_item.position = carry_position.position
		

func update_climb_facing():
	if climb_target:
		var target_dir = climb_target.global_position.x - global_position.x
		climb_facing_right = target_dir > 0
		sprite.flip_h = !climb_facing_right

func handle_damaged_state(source_position: Vector2):
	if is_invincible:
		exit_damaged_state()
		return
	
	# Применяем отбрасывание
	var knockback_dir = sign(global_position.x - source_position.x)
	velocity = Vector2(knockback_dir * DAMAGE_KNOCKBACK.x, DAMAGE_KNOCKBACK.y)
	
	# Запускаем неуязвимость
	start_invincibility()
	
	# Уменьшаем жизни
	Global.lose_life()
		
	exit_damaged_state()

func handle_interaction_state():	
	if carried_item:
		# Бросаем предмет
		release_item()
	else:
		# Пытаемся подобрать предмет
		try_pickup_item()
	exit_interaction_state()

func start_invincibility():
	is_invincible = true
	invincibility_timer.start(INVINCIBILITY_DURATION)
	
	# Включаем эффект мигания
	$AnimationPlayer.play("invincibility_flash")
	
	# Меняем слой коллизий
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)

func _end_invincibility():
	is_invincible = false
	$AnimationPlayer.stop()
	
	# Восстанавливаем слои коллизий
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, false)
	
func try_pickup_item():
	var nearest_item = get_nearest_collectible()
	if nearest_item:
		if nearest_item.is_in_group("Memory"):
			print("Pensilpoe")
		elif nearest_item.is_in_group("Items"):
			pickup_item(nearest_item)
	
func get_nearest_collectible() -> Node2D:
	var closest_distance = INF
	var closest_item = null
	
	for item in $ItemDetector.get_overlapping_bodies():
		print(item)
		var distance = global_position.distance_to(item.global_position)
		if distance < closest_distance and (item.is_in_group("Items") or item.is_in_group("Memory")):
			closest_distance = distance
			closest_item = item
	return closest_item

func pickup_item(item: RigidBody2D):
	if carried_item != null:
		return

	print("Подбираем: ", item.name, " | Видимый: ", item.visible)
	
	# Сохраняем исходные параметры
	original_item_parent = item.get_parent()
	original_item_collision_layer = item.collision_layer
	
	# Переносим объект к коту
	original_item_parent.remove_child(item)
	add_child(item)
	
	# Настраиваем позицию и физику
	item.global_position = $CarryPosition.global_position
	item.rotation = 0
	item.freeze = true
	item.collision_layer = 0
	item.visible = true
	
	carried_item = item

func release_item():
	if carried_item == null:
		return
	
	print("Отпускаем: ", carried_item.name, " | Видимый: ", carried_item.visible)
	
	# Рассчитываем позицию с учетом направления кота
	var release_pos = carry_position.global_position
	if sprite.flip_h:
		# Инвертируем позицию маркера относительно кота
		release_pos.x -= carry_position.position.x * 2
	
	# Возвращаем в исходного родителя
	remove_child(carried_item)
	original_item_parent.add_child(carried_item)
	
	# Обновляем позицию
	carried_item.global_position = release_pos
	carried_item.freeze = false
	carried_item.collision_layer = original_item_collision_layer
	carried_item.visible = true
	
	carried_item = null	

# ===== СИСТЕМА СОСТОЯНИЙ =====
func enter_crouch_state():
	current_state = State.CROUCHING
	sprite.play("crouch_start")

func exit_crouch_state():
	current_state = State.NORMAL
	sprite.play("crouch_end")
	await sprite.animation_finished

func enter_interaction_state():
	current_state = State.INTERACTION

func exit_interaction_state():
	current_state = State.NORMAL

func enter_climb_state():
	current_state = State.CLIMBING
	sprite.play("climb_idle")
	await sprite.animation_finished

func exit_climb_state(forced: bool):
	current_state = State.NORMAL
	sprite.play("climb_end")	
	# Принудительный выход сохраняет блокировку
	if forced:
		ignore_climb_until_exit = true
	await sprite.animation_finished

func enter_damaged_state():
	current_state = State.DAMAGED
	#sprite.play("damage")
	await sprite.animation_finished

func exit_damaged_state():
	current_state = State.NORMAL

func start_meow():
	current_state = State.MEOW
	$Sounds/CatMeowSound.play()
	sprite.play("meow")
	await sprite.animation_finished
	current_state = State.NORMAL

func start_lick():
	current_state = State.LICK
	sprite.play("lick")
	await sprite.animation_finished
	current_state = State.NORMAL

# ===== СИГНАЛЫ =====
func _on_climb_area_entered(body):
	# Такой номер у слоя climbable
	if body.collision_layer == 4 and body not in entered_climb_areas:
		entered_climb_areas.append(body)
		is_climbing_possible = true
		climb_target = body

func _on_climb_area_exited(body):
	if body in entered_climb_areas:
		entered_climb_areas.erase(body)
		is_climbing_possible = not entered_climb_areas.is_empty()
		# Сбрасываем блокировку при выходе из всех зон
		if entered_climb_areas.is_empty():
			ignore_climb_until_exit = false
			climb_target = null
		else:
			climb_target = entered_climb_areas[0]

func _on_sprite_animation_finished():
	if current_state == State.CROUCHING and sprite.animation == "crouch_start":
		# Фиксируем последний кадр
		sprite.frame = sprite.sprite_frames.get_frame_count("crouch_start") - 1
func die():
	var music_player = get_node("Sounds/Music")  # Путь к вашей ноде с музыкой
	if music_player:
		music_player.stop()
	
	current_state = State.DEAD
	sprite.play("death")
	await get_tree().create_timer(2).timeout

	Global.lose_life() 
	  
