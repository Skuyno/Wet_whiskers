extends CharacterBody2D

# Настройки движения
const WALK_SPEED = 70.0
const CROUCH_SPEED = 50.0
const JUMP_FORCE = -150.0
const CLIMB_SPEED = 60.0
const GRAVITY = 980.0

# Состояния персонажа
enum State {
	NORMAL,
	CROUCHING,
	CLIMBING,
	MEOW,
	LICK
}

# Экспортируемые переменные
@export var current_state: State = State.NORMAL
@onready var sprite = $CatSprite
@onready var climb_detector = $ClimbArea

# Системные переменные
var is_climbing_possible = false
var can_exit_climb = false
var exit_delay = 0.2
var exit_timer = 0.0
var climb_target: Node2D = null
var climb_facing_right: bool = true
var ignore_climb_until_exit = false
var entered_climb_areas = []

func _ready():
	# Настройка соединений сигналов
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	$ClimbArea.area_entered.connect(_on_climb_area_entered)
	$ClimbArea.area_exited.connect(_on_climb_area_exited)

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
	
	# Применяем движение
	move_and_slide()
	
	# Обновляем анимации
	update_animations()

func handle_normal_state(delta):
	# Гравитация
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
	
	# Горизонтальное движение
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * WALK_SPEED
	
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

func handle_crouch_state(delta):
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
	
	# Выход при нажатии вверх (прыжок от стены)
	if Input.is_action_pressed("ui_up") and not is_climbing_possible:
		velocity.y = JUMP_FORCE * 1.25
		exit_climb_state(true)
		return
	
	# Автоматический выход если нет доступных зон
	if entered_climb_areas.is_empty():
		exit_climb_state(false)
		return
	
	# Плавный выход при покидании зоны
	if not is_climbing_possible:
		exit_climb_state(false)

func handle_special_animations():
	# Блокируем движение во время специальных анимаций
	velocity = Vector2.ZERO

func update_animations():
	if current_state == State.MEOW or current_state == State.LICK:
		return  # Не прерываем специальные анимации
	
	match current_state:
		State.NORMAL:
			if not is_on_floor():
				sprite.play("jump" if velocity.y < 0 else "fall")
			else:
				sprite.play("walk" if abs(velocity.x) > 0 else "idle")
		
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
		

func update_climb_facing():
	if climb_target:
		var target_dir = climb_target.global_position.x - global_position.x
		climb_facing_right = target_dir > 0
		sprite.flip_h = !climb_facing_right

# ===== СИСТЕМА СОСТОЯНИЙ =====
func enter_crouch_state():
	current_state = State.CROUCHING
	sprite.play("crouch_start")

func exit_crouch_state():
	current_state = State.NORMAL
	sprite.play("crouch_end")
	await sprite.animation_finished

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

func start_meow():
	current_state = State.MEOW
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
	if body.is_in_group("climbable") and body not in entered_climb_areas:
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
