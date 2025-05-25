extends Area2D

@export var animation_duration: float = 3.5
@export var start_scale: float = 0.2
@export var end_scale: float = 0.8
@export var activation_scale: float = 0.65
@export var lane_width: float = 150.0

var tween: Tween
var collision_active: bool = false
var initial_collision_shape: Shape2D  # Сохраняем исходную форму

func _ready():
	# Загрузка текстуры
	var textures = [
		"res://assets/sprites/level2/car_1d.png",
		"res://assets/sprites/level2/car_2d.png",
		"res://assets/sprites/level2/car_3d.png",
		"res://assets/sprites/level2/car_4d.png",
		"res://assets/sprites/level2/car_5d.png",
		"res://assets/sprites/level2/car_6d.png",
		"res://assets/sprites/level2/car_7d.png",
	]
	$Sprite2D.texture = load(textures[randi() % textures.size()])
	
	# Копируем исходную форму коллизии для уникальности
	initial_collision_shape = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape = initial_collision_shape
	
	$CollisionShape2D.disabled = true
	scale = Vector2(start_scale, start_scale)
	modulate.a = 1.0
	
	tween = create_tween()
	tween.tween_method(_update_scale, start_scale, end_scale, animation_duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, animation_duration * 0.3).set_delay(animation_duration * 0.7)
	tween.tween_callback(queue_free)

func _update_scale(current_scale: float):
	scale = Vector2(current_scale, current_scale)
	
	if current_scale >= activation_scale and not collision_active:
		collision_active = true
		$CollisionShape2D.disabled = false
		initial_collision_shape.size = $CollisionShape2D.shape.size * (current_scale / start_scale)

func _on_body_entered(body):
	if body.name == "Cat" and collision_active:
		$CrashSound.play()
		await get_tree().create_timer(0.25).timeout
		Global.lose_life()
