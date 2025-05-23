extends Node2D

var can_interact = false
var has_interacted = false
@onready var player = get_tree().get_first_node_in_group("player") # Более надежный способ
@onready var collision_shape = $Area2D/CollisionShape2D

@onready var animation_player = $"../Memory/TextureRect/AnimationPlayer"
@onready var texture_rect = $"../Memory/TextureRect"
@onready var cletka = $Sprite2D/AnimationPlayer

var is_cutscene_playing = false
@export var cutscene_duration = 10
func _ready():
	cletka.play("cletka")
	texture_rect.z_index = 100  # Делаем поверх всех элементов
	
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		print("Player can interact")

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false

func _input(event):
	if event.is_action_pressed("interact") and can_interact and not is_cutscene_playing:
		interact()

func interact():
	if has_interacted :  # Проверяем, было ли уже взаимодействие
		return
		
	has_interacted = true
	
	is_cutscene_playing = true
	
	# Блокируем управление персонажем
	if player:
		player.set_process_input(false)
		player.set_physics_process(false)
	
	# Запускаем катсцену
	start_cutscene()
	
	# Ждем окончания катсцены
	await get_tree().create_timer(cutscene_duration).timeout
	end_cutscene()

func start_cutscene():
	# Делаем TextureRect на весь экран (на случай изменения размера окна)
	$"../Sounds/Music".stop()

	texture_rect.visible = true
	$"../Sounds/Memory".play()
	
	if animation_player.has_animation("appear"):
		animation_player.play("appear")
		await animation_player.animation_finished
		
		await get_tree().create_timer(7).timeout
		
		if animation_player.has_animation("disappear"):
			animation_player.play("disappear")
			await animation_player.animation_finished
	
	texture_rect.visible = false

func end_cutscene():
	is_cutscene_playing = false
	$"../Sounds/Memory".stop()
	$"../Sounds/Music".play()
	cletka.stop()
	# Восстанавливаем управление персонажем
	if player:
		player.set_process_input(true)
		player.set_physics_process(true)
