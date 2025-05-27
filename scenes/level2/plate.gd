extends Node2D

var can_interact = false
var has_interacted = false
@onready var player = get_tree().get_first_node_in_group("player")
@onready var player_camera = get_tree().get_first_node_in_group("camera")
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var texture_rect = $"1"
@onready var animation_player = $Sprite2D/AnimationPlayer

var is_cutscene_playing = false
@export var first_slide_duration: float = 3.0  # Длительность первого слайда
@export var second_slide_duration: float = 7.0  # Длительность второго слайда
@export var fade_duration: float = 1.0
@export var slides: Array[Texture2D] = []  # Должно содержать 2 текстуры

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
	if body.is_in_group("player") and not has_interacted:
		can_interact = true
		print("Player can interact with slideshow")

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false

func _input(event):
	if event.is_action_pressed("interact") and can_interact and not is_cutscene_playing:
		interact()

func interact():
	if has_interacted or slides.size() != 2:  # Проверяем что есть ровно 2 слайда
		return
	
	save_game()
	has_interacted = true
	print("Starting slideshow with 2 slides")
	is_cutscene_playing = true
	
	if player:
		player.set_process_input(false)
		player.set_physics_process(false)
	
	start_cutscene()

func start_cutscene():
	$"../Sounds/Music".stop()
	$"../Sounds/cafe".stop()
	$"../Sounds/Mem2".play()

	
	# Показываем TextureRect
	texture_rect.visible = true
	texture_rect.texture = slides[0]
	current_slide_index = 0
	
	# Проигрываем звук для первого слайда
	$"../Sounds/arguing".play()
	
	# Плавное появление первого слайда
	var appear_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	appear_tween.tween_property(texture_rect, "modulate:a", 1.0, fade_duration)
	await appear_tween.finished
	
	# Ждем перед вторым слайдом (первый слайд длится first_slide_duration секунд)
	await get_tree().create_timer(first_slide_duration).timeout
	
	# Плавный переход ко второму слайду
	var change_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	change_tween.tween_property(texture_rect, "modulate:a", 1, fade_duration/2)
	await change_tween.finished
	
	# Меняем на второй слайд
	texture_rect.texture = slides[1]
	current_slide_index = 1
	
	# Проигрываем звук для второго слайда
	$"../Sounds/arguing".stop()
	$"../Sounds/Plateboom".play()
		
	# Возвращаем полную видимость
	change_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	change_tween.tween_property(texture_rect, "modulate:a", 1.0, fade_duration/2)
	await change_tween.finished
	
	# Ждем перед завершением (второй слайд длится second_slide_duration секунд)
	await get_tree().create_timer(second_slide_duration).timeout
	
	# Плавное исчезновение
	var disappear_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	disappear_tween.tween_property(texture_rect, "modulate:a", 0.0, fade_duration)
	await disappear_tween.finished
	
	texture_rect.visible = false
	end_cutscene()

func end_cutscene():
	animation_player.stop()
	print("Slideshow finished")
	is_cutscene_playing = false
	$"../Sounds/Mem2".stop()
	$"../Sounds/cafe".play()
	$"../Sounds/Music".play()
	
	if player:
		player.set_process_input(true)
		player.set_physics_process(true)
