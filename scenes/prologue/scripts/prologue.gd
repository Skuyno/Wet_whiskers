extends Node2D

func _ready():
	# Начальная настройка
	set_audio_volume_rain_car(-30.0)  # Начальная громкость
	$UI/BlackSquare.visible = true
	
	$Car/Camera2D.make_current()
	$AudioPlayers/Music.play()
	$AudioPlayers/RainAndEngineInCarSound.play()
	$AnimationPlayer.play("CarArrival")
	create_fade_tween_in_car(6.0)
	await $AnimationPlayer.animation_finished
	$AudioPlayers/RainAndEngineInCarSound.stop()
	$AudioPlayers/EngineOffSound.play()
	$AudioPlayers/RainInCarSound.play()
	$Car/AnimatedSprite2D.stop()
	await $AudioPlayers/EngineOffSound.finished
	await get_tree().create_timer(5.0).timeout
	$AudioPlayers/RainInCarSound.stop()
	$AudioPlayers/DoorOpenAndCloseSound.play
	spawn_character()
	$AudioPlayers/DoorOpenAndCloseSound.play()
	$AudioPlayers/RainOutside.play()
	await $AudioPlayers/DoorOpenAndCloseSound.finished
	character_actions()
	cat_actions()
	await character_actions()
	await cat_actions()
	create_fade_out_tween_outside(3.0)
	await get_tree().create_timer(3.0).timeout
	
	$Cat/AnimatedSprite2D/Camera2D.make_current()
	$Cat/AnimatedSprite2D.global_position = $PipeEntryPoint.global_position
	$Cat/AnimatedSprite2D.visible = true
	create_fade_tween_outside(4.0)
	await get_tree().create_timer(0.5).timeout
	pipe_climb_sequence()
	
func set_audio_volume_rain_car(db: float):
	$AudioPlayers/RainAndEngineInCarSound.volume_db = db
	
func set_audio_volume_rain_outside(db: float):
	$AudioPlayers/RainOutside.volume_db = db

func create_fade_tween_in_car(duration: float):
	var tween = create_tween().set_parallel(true)
	
	# Анимация звуков
	tween.tween_method(set_audio_volume_rain_car.bind(), -30.0, 0.0, duration)
	
	# Анимация затемнения
	tween.tween_property($UI/BlackSquare, "color:a", 0.0, duration)\
		 .set_ease(Tween.EASE_IN_OUT)\
		 .set_trans(Tween.TRANS_SINE)
	
func create_fade_tween_outside(duration: float):
	var tween = create_tween().set_parallel(true)
	
	# Анимация звуков
	tween.tween_method(set_audio_volume_rain_outside.bind(), -30.0, 0.0, duration)
	
	# Анимация затемнения экрана
	tween.tween_property($UI/BlackSquare, "color:a", 0.0, duration)\
		 .set_ease(Tween.EASE_IN_OUT)\
		 .set_trans(Tween.TRANS_SINE)
		
func create_fade_out_tween_outside(duration: float):
	var tween = create_tween().set_parallel(true)
	
	# Анимация затухания звуков
	tween.tween_method(set_audio_volume_rain_outside.bind(), 0.0, -30.0, duration)
	
	# Анимация затемнения экрана
	tween.tween_property($UI/BlackSquare, "color:a", 1.0, duration)\
		 .set_ease(Tween.EASE_IN_OUT)\
		 .set_trans(Tween.TRANS_SINE)

func spawn_character():
	# 1. Инициализация персонажа
	var character = $Person/AnimatedSprite2D
	character.visible = true
	character.modulate.a = 0  # Начальная прозрачность
	
	# 2. Позиционирование у машины
	character.global_position = $Car/SpawnPoint.global_position
	
	# 3. Анимация появления
	var tween = create_tween().set_parallel()
	tween.tween_property(character, "modulate:a", 1.0, 1.5)
	
	await tween.finished
	
func _process(delta):
	if Input.is_action_just_pressed("skip"):
		get_tree().change_scene_to_file("res://scenes/level1/level1.tscn")

func character_actions():
	# Запуск анимации ходьбы
	var character = $Person/AnimatedSprite2D
	character.play("walk")
	
	# Движение до задней двери
	var target_position1 = $Car/BackDoorPoint.global_position
	var walk_duration1 = (target_position1 - character.global_position).length() / 20.0  # 100 px/s
	
	var tween1 = create_tween()
	tween1.tween_property(character, "global_position", target_position1, walk_duration1)
	tween1.tween_callback(func():
		character.flip_h = true
		character.play("idle")
	)
	await tween1.finished
	$AudioPlayers/DoorOpenSound.play()
	await $AudioPlayers/DoorOpenSound.finished
	$Car/AnimatedSprite2D.play("cat_jump")
	$AudioPlayers/MoneyBagSound.play()
	character.play("idle_with_bag")
	await get_tree().create_timer(3.0).timeout
	await get_tree().create_timer(1.0).timeout
	
	character.play("walk_with_bag")
	
	# Движение за экран
	var target_position2 = $PersonExitPoint.global_position
	var walk_duration2 = (target_position2 - character.global_position).length() / 40.0  # 100 px/s
	
	var tween2 = create_tween()
	tween2.tween_property(character, "global_position", target_position2, walk_duration2)
	tween2.tween_callback(func(): 
		character.stop()
		character.hide()
	)
	
	await tween2.finished

func cat_actions():
	var cat = $Cat/AnimatedSprite2D
	
	await $Car/AnimatedSprite2D.animation_finished
	cat.visible = true;
	
	cat.play("idle")
	await get_tree().create_timer(2.0).timeout
	
	# Начало движения кота
	cat.play("walk")
	var target_positions = [
		$CatExitPoint1.global_position,
		$CatExitPoint2.global_position
	]
	
	# Движение по точкам
	for target in target_positions:
		var distance = (target - cat.global_position).length()
		var duration = distance / 60.0  # 60 пикселей в секунду
		
		# Поворот спрайта по направлению движения
		cat.flip_h = target.x < cat.global_position.x
		
		var tween = create_tween()
		tween.tween_property(cat, "global_position", target, duration)
		await tween.finished
		
		# Анимация паузы между движениями
		if target == target_positions[0]:
			cat.play("idle")
			await get_tree().create_timer(3.0).timeout
			cat.play("meow")
			$AudioPlayers/CatMeowSound.play()
			await get_tree().create_timer(4.0).timeout
			cat.play("walk")
			
	cat.hide()

func pipe_climb_sequence():
	var cat = $Cat/AnimatedSprite2D
	
	# Анимация лазания по трубе
	cat.play("climb_up")
	
	var tween_pipe = create_tween()
	tween_pipe.tween_property(cat, "global_position", 
		$PipeExitPoint.global_position, 
		($PipeExitPoint.global_position - cat.global_position).length() / 20
	)
	await tween_pipe.finished
	
	# Переход на крышу
	cat.play("walk")
	var tween_roof = create_tween()
	tween_roof.tween_property(cat, "global_position", 
		$RoofPoint.global_position, 
		2.5
	)
	await tween_roof.finished
	
	# Финал анимации
	cat.play("sitting")
	await get_tree().create_timer(3).timeout
	$AudioPlayers/CatMeowSound.play()
	
	await get_tree().create_timer(3.0).timeout
	
	create_fade_out_tween_outside(5.0)
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://scenes/level1/level1.tscn")
