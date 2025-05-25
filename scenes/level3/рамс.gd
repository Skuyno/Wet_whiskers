extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)  # Добавляем обработчик выхода

var road_sound: AudioStreamPlayer
var road_sound2: AudioStreamPlayer  # Храним ссылку на звук
var sound_playing := false  # Флаг состояния звука

func _on_body_entered(body):
	if body.name == "Cat" or body.is_in_group("player"):
		# Получаем звук по абсолютному пути
		road_sound = get_node_or_null("/root/Level3/Sounds/rams")
		road_sound2 = get_node_or_null("/root/Level3/Sounds/aoaoao")
		
		if (road_sound and not sound_playing) and (road_sound2 and not sound_playing):
			road_sound.play()
			road_sound2.play()
			sound_playing = true

func _on_body_exited(body):
	if (body.name == "Cat" or body.is_in_group("player")) and road_sound and road_sound2 and sound_playing:
		road_sound.stop()
		road_sound2.stop()
		sound_playing = false
