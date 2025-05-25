extends RigidBody2D

@onready var impact_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	gravity_scale = 0.1
	linear_velocity = Vector2(0, 30)
	
	if impact_sound:
		impact_sound.max_distance = 500
		impact_sound.attenuation = 1.0
		impact_sound.volume_db = 0
	
	$Area2D.area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if area.is_in_group("delete_zone"):
		play_impact_sound()

func play_impact_sound():
	if not impact_sound:
		queue_free()
		return
	
	# Создаем новый независимый звуковой игрок
	var new_sound = impact_sound.duplicate()
	get_tree().current_scene.add_child(new_sound)
	new_sound.global_position = global_position
	new_sound.play()
	
	# Удаляем звук после воспроизведения
	new_sound.finished.connect(new_sound.queue_free)
	
	# Удаляем основной объект
	queue_free()
