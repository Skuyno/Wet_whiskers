# Train.gd
extends Path2D

@export var move_speed: float = 800.0  # Пикселей в секунду
@export var spawn_interval: float = 7.0  # Интервал между поездами
@export var horn_sound: AudioStream

@onready var train_sprite = $TrainSprite

func _ready():
	start_spawn_cycle()

func start_spawn_cycle():
	while true:
		# Гудок за 2 секунды до поезда
		$HornPlayer.play()
		
		# Ждем перед появлением поезда
		await get_tree().create_timer(5.0).timeout
		
		# Создаем поезд
		var train_instance = train_sprite.duplicate()
		add_child(train_instance)
		
		# Начальная позиция справа за экраном
		train_instance.position = Vector2(400, 0)  # Подберите значение под ваш экран
		
		var tween = create_tween()
		tween.tween_property(train_instance, "position:x", 5000, 5.0)  # Быстрое движение!
		tween.tween_callback(train_instance.queue_free)
		
		# Интервал до следующего гудка
		await get_tree().create_timer(spawn_interval).timeout
