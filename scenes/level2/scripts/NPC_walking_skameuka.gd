extends CharacterBody2D

@export var move_distance: float = 100.0
@export var speed: float = 50.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var default_collision_layer: int = 1
@export var default_collision_mask: int = 1

var start_x: float
var target_x: float
var is_moving: bool = true
var direction: int = 1
var timer: Timer
var collision_disabled: bool = false
var bench_areas_count: int = 0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bench"):
		bench_areas_count += 1
		_update_collision_state()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("bench"):
		bench_areas_count = max(0, bench_areas_count - 1)
		_update_collision_state()

func _update_collision_state():
	var should_disable = bench_areas_count > 0
	
	if should_disable:
		collision_layer = 0
		collision_mask = 0
	else:
		collision_layer = default_collision_layer
		collision_mask = default_collision_mask
