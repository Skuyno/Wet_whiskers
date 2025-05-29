extends Area2D

@export var slide_duration: float = 4.0
@export var fade_duration: float = 1.0
@export var slides: Array[Texture2D] = []  # Должно содержать 3 текстуры
@export var sound_3rd_slide: AudioStream

var current_slide_index := 0
var is_cutscene_playing := false
var has_played := false

@onready var texture_rect = $"../1"
@onready var audio_player = $"../../Sounds/stuk"
@onready var black_screen = $BlackScreen  # Добавляем черный экран

func _ready():
	# Настройка TextureRect
	texture_rect.visible = false
	texture_rect.modulate.a = 0
	
	# Настройка черного экрана
	if not black_screen:
		black_screen = ColorRect.new()
		black_screen.color = Color.BLACK
		black_screen.size = get_viewport_rect().size
		black_screen.visible = false
		add_child(black_screen)
	
	# Подключаем сигнал касания
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and not is_cutscene_playing and not has_played:
		if Global.collected_memories.size() == 5:
			print("pipiska")
		else:
			start_slideshow()

func start_slideshow():
	$"../../Sounds/Music".stop()
	$"../../Sounds/vetr".play()
	if slides.size() < 3:
		push_error("Need exactly 3 slides for this slideshow")
		return
	
	has_played = true
	is_cutscene_playing = true
	
	# Блокируем управление игроком
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_process_input(false)
		player.set_physics_process(false)
	
	# Запускаем последовательность слайдов
	show_slide(0)
	await get_tree().create_timer(slide_duration).timeout
	
	show_slide(1)
	await get_tree().create_timer(slide_duration).timeout
	
	# Третий слайд с особым звуком
	show_slide(2)
	$"../../Sounds/stuk".play()
	
	await get_tree().create_timer(slide_duration).timeout
	end_slideshow()

func show_slide(index: int):
	current_slide_index = index
	texture_rect.texture = slides[index]
	
	# Анимация появления
	texture_rect.visible = true
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished
	
	# Ждем основное время показа
	await get_tree().create_timer(slide_duration - fade_duration * 2).timeout
	
	# Анимация исчезновения (кроме последнего слайда)
	if index < 2:
		tween = create_tween()
		tween.tween_property(texture_rect, "modulate:a", 1.0, fade_duration)  # Исправлено на 0.0 для исчезновения
		await tween.finished

func end_slideshow():
	# Плавное появление черного экрана
	black_screen.visible = true
	black_screen.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(black_screen, "modulate:a", 1.0, fade_duration * 2)  # Медленное затемнение
	await tween.finished
	
	# Останавливаем все звуки
	$"../../Sounds/vetr".stop()
	$"../../Sounds/stuk".stop()
	
	# Скрываем TextureRect
	texture_rect.visible = false
	is_cutscene_playing = false
	
	# Навсегда блокируем управление (конец игры)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.queue_free()  # Удаляем игрока
	
	# Дополнительно можно добавить:
	get_tree().paused = true  # Пауза игры
	# Или: get_tree().quit()  # Для выхода из игры
