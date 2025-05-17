extends CharacterBody2D

@export var move_distance: float = 100.0
@export var speed: float = 50.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0

var start_x: float
var target_x: float
var is_moving: bool = true
var direction: int = 1
var timer: Timer

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	start_x = global_position.x
	target_x = start_x + move_distance
	
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if is_moving:
		var new_x = move_toward(global_position.x, target_x, speed * delta)
		global_position.x = new_x
		
		if is_equal_approx(global_position.x, target_x):
			_start_idle()
			_swap_direction()
		
		_update_animation()

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
