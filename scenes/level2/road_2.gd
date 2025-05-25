extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)  # Добавляем обработчик выхода

var road_sound: AudioStreamPlayer  # Храним ссылку на звук
var sound_playing := false  # Флаг состояния звука

func _on_body_entered(body):
	if body.name == "Cat" or body.is_in_group("player"):
		# Получаем звук по абсолютному пути
		road_sound = get_node_or_null("/root/Level2/Sounds/traffic")
		
		if road_sound and not sound_playing:
			road_sound.play()
			sound_playing = true

func _on_body_exited(body):
	if (body.name == "Cat" or body.is_in_group("player")) and road_sound and sound_playing:
		road_sound.stop()
		sound_playing = false
