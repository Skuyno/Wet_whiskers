# Train.gd
extends Path2D

@export var move_speed: float = 800.0
@export var spawn_interval: float = 7.0
@export var horn_sound: AudioStream

@onready var train_sprite = $TrainSprite

var is_in_train_zone : bool = false

func _ready():
	start_spawn_cycle()

func start_spawn_cycle():
	while true:
		if is_in_train_zone:
			var sounds = [$HornPlayer1, $HornPlayer2]
			var random_horn = sounds[randi() % sounds.size()]
			random_horn.play()
		
		await get_tree().create_timer(5.0).timeout
		
		var train_instance = train_sprite.duplicate()
		add_child(train_instance)
		train_instance.position = Vector2(400, 0)
		
		# Настраиваем обработчик коллизий для каждого поезда
		var hitbox = train_instance.get_node("Hitbox")
		hitbox.body_entered.connect(
			func(body):
				if body.name == "Cat":
					print(body)
					Global.lose_life()
		)
		
		var tween = create_tween()
		tween.tween_property(train_instance, "position:x", 5000, 5.0)
		tween.tween_callback(train_instance.queue_free)
		
		await get_tree().create_timer(spawn_interval).timeout

# Остальной код без изменений
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Cat":
		is_in_train_zone = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Cat":
		is_in_train_zone = false
