extends CharacterBody2D

@export var animation_duration: float = 2.0
@export var start_scale: float = 0.2
@export var end_scale: float = 0.8
@export var lane_width: float = 150.0

var tween: Tween

func _ready():
	# Загрузка текстуры
	var textures = [
		"res://assets/sprites/level2/car_1d.png",
		"res://assets/sprites/level2/car_2d.png",
	]
	$Sprite2D.texture = load(textures[randi() % textures.size()])
	
	# Начальные значения
	scale = Vector2(start_scale, start_scale)
	modulate.a = 1.0  # Явно устанавливаем полную непрозрачность
	
	# Настройка анимации
	tween = create_tween()
	
	# Анимация масштаба - вся длительность
	tween.tween_property(self, "scale", 
		Vector2(end_scale, end_scale), 
		animation_duration
	)
	
	# Анимация прозрачности - начинается позже
	tween.parallel().tween_property(self, "modulate:a", 0.0, animation_duration * 0.3
	).set_delay(animation_duration * 0.7)  # Начинаем через 70% времени
	
	tween.tween_callback(queue_free)
