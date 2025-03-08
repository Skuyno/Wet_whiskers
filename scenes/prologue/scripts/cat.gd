#extends CharacterBody2D
#
#
#const SPEED = 100.0
#const JUMP_VELOCITY = -200.0
#
#@onready var anim = $CatSprite
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#anim.play("jump")
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
		#if velocity.y == 0:
			#anim.play("walk")
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#if velocity.y == 0:
			#anim.play("stay")
		#
	#if direction == -1:
		#anim.flip_h = true
	#elif direction == 1:
		#anim.flip_h = false
		#
	#if velocity.y > 0:
		#anim.play("down")
#
	#move_and_slide()
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
var was_on_floor = false

func _ready():
	# Настройка соединений сигналов
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	$ClimbArea.area_entered.connect(_on_climb_area_entered)
	$ClimbArea.area_exited.connect(_on_climb_area_exited)

func _physics_process(delta):
	# Сохраняем предыдущее состояние пола
	was_on_floor = is_on_floor()
	
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
	print(current_state)
	
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
	if Input.is_action_just_pressed("ui_up") and is_climbing_possible:
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
	
	# Выходи из лазания через спрыгивание
	var horizontal = Input.get_axis("ui_left", "ui_right")
	if horizontal != 0:
		velocity = Vector2(horizontal * WALK_SPEED, 0)
		exit_climb_state()
	
	# Выход из лазания
	if not is_climbing_possible:
		exit_climb_state()

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
	sprite.play("climb_start")
	await sprite.animation_finished

func exit_climb_state():
	current_state = State.NORMAL
	sprite.play("climb_end")
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
	if body.is_in_group("climbable"):
		is_climbing_possible = true

func _on_climb_area_exited(body):
	if body.is_in_group("climbable"):
		is_climbing_possible = false
		
func _on_sprite_animation_finished():
	if current_state == State.CROUCHING and sprite.animation == "crouch_start":
		# Фиксируем последний кадр
		sprite.frame = sprite.sprite_frames.get_frame_count("crouch_start") - 1
