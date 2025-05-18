extends CharacterBody2D

@export var move_distance: float = 220.0
@export var speed: float = 50.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var fade_duration: float = 1.0
@export var pharmacy_stop_position: float = 270.0
@export var shop_stop_position: float = -68.0  # X-координата точки остановки у аптеки

var start_x: float
var target_x: float
var is_moving: bool = true
var direction: int = 1
var timer: Timer
var is_hidden: bool = false

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	start_x = global_position.x
	target_x = start_x + move_distance
	
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	
	if is_hidden:
		return
		
	if is_moving:
		var new_x = move_toward(global_position.x, target_x, speed * delta)
		global_position.x = new_x
		
		if abs(global_position.x - pharmacy_stop_position) < 5.0 or abs(global_position.x - shop_stop_position) < 3.0:
			_start_hiding()
			return
			
		if is_equal_approx(global_position.x, target_x):
			_start_idle()
			_swap_direction()
		
		_update_animation()

func _start_hiding():
	is_moving = false
	# Плавное исчезновение
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(func(): is_hidden = true)
	tween.tween_interval(5.0)  # 20 секунд невидимости
	tween.tween_callback(_start_appearing)

func _start_appearing():
	# Плавное появление
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 1.0, fade_duration)
	tween.tween_callback(func(): 
		is_hidden = false
		_swap_direction()
		is_moving = true
	)

func _swap_direction():
	direction *= -1
	target_x = start_x + (move_distance * direction)
	animated_sprite.flip_h = direction < 0

func _update_animation():
	if is_moving:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func _start_idle():
	is_moving = false
	timer.wait_time = randf_range(min_idle_time, max_idle_time)
	timer.start()

func _on_timer_timeout():
	is_moving = true
