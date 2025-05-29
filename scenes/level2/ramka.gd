extends Node2D

var can_interact = false
var has_interacted = false  # Добавьте эту переменную в начало скрипта
@onready var player = get_tree().get_first_node_in_group("player")
@onready var player_camera = get_tree().get_first_node_in_group("camera")
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var texture_rect = $"1"  # Один TextureRect для всех слайдов
@onready var animation_player = $Sprite2D/AnimationPlayer

var is_cutscene_playing = false
@export var slide_duration: float = 3.0
@export var fade_duration: float = 1.0   # Длительность перехода между слайдами
@export var slides: Array[Texture2D] = []  # Массив текстур для слайдов

var current_slide_index := 0
var camera_size: Vector2
var tween: Tween

var save_path = "res://savegame.save"
func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(player.position.x)
	file.store_var(player.position.y)
	
func _ready():
	animation_player.play("cletka")
	if player_camera:
		camera_size = player_camera.get_viewport_rect().size
	else:
		camera_size = get_viewport_rect().size
		push_warning("Player camera not found, using viewport size")
	
	# Инициализация TextureRect
	if texture_rect:
		texture_rect.z_index = 100
		texture_rect.modulate.a = 0
		texture_rect.visible = false
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		
	else:
		push_error("TextureRect not found!")
	
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		print("Player can interact with slideshow")

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false

func _input(event):
	if event.is_action_pressed("interact") and can_interact and not is_cutscene_playing:
		interact()

func interact():
	if has_interacted or slides.size() == 0:  # Проверяем, было ли уже взаимодействие
		return
		
	if slides.size() == 0:
		push_error("No slides added to slideshow!")
		return
	
	save_game()
	has_interacted = true  # Помечаем, что взаимодействие произошло
	print("Starting slideshow with ", slides.size(), " slides")
	is_cutscene_playing = true
	
	# Блокировка управления игроком
	if player:
		player.set_process_input(false)
		player.set_physics_process(false)
	
	Global.collected_memories.append("Ramka")
	
	start_cutscene()

func start_cutscene():
	$"../Sounds/Music".stop()
	$"../Sounds/Memory".play()
	

	
	# Показываем TextureRect
	texture_rect.visible = true
	texture_rect.texture = slides[0]
	current_slide_index = 0
	
	# Плавное появление первого слайда
	var appear_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	$"../Sounds/Myau".play()
	appear_tween.tween_property(texture_rect, "modulate:a", 1.0, fade_duration)
	await appear_tween.finished
	$"../Sounds/Myau".stop()
	

	await run_slideshow()

	
	# Плавное исчезновение последнего слайда
	var disappear_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	disappear_tween.tween_property(texture_rect, "modulate:a", 0.0, fade_duration)
	await disappear_tween.finished
	
	texture_rect.visible = false
	end_cutscene()

func run_slideshow():
	for i in range(1, slides.size()):
		# Ждем перед переходом к следующему слайду
		await get_tree().create_timer(slide_duration).timeout
		
		var is_last_four = i >= (slides.size() - 4)
		
		# Плавная смена слайда (без полного исчезновения)
		var change_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# Слегка уменьшаем прозрачность (до 0.7 вместо 0)
		change_tween.tween_property(texture_rect, "modulate:a", 1, fade_duration/2)
		await change_tween.finished
		
		# Меняем текстуру
		texture_rect.texture = slides[i]
		current_slide_index = i
		print("Changed to slide ", i)
		
		if is_last_four:
			$"../Sounds/Murk".play()
			
		# Возвращаем полную видимость
		change_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		change_tween.tween_property(texture_rect, "modulate:a", 1.0, fade_duration/2)
		await change_tween.finished

func end_cutscene():
	animation_player.stop()
	print("Slideshow finished")
	is_cutscene_playing = false
	$"../Sounds/Memory".stop()
	$"../Sounds/Murk".stop()
	$"../Sounds/Music".play()
	
	# Восстанавливаем управление персонажем
	if player:
		player.set_process_input(true)
		player.set_physics_process(true)
