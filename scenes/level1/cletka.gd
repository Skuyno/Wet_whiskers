extends Node2D

# Если true, игрок может взаимодействовать
var can_interact = false
var save_path = "res://savegame.save"
@onready var player = $"../Cat"

# Настройка формы коллизии (если она меняется)
@onready var collision_shape = $Area2D/CollisionShape2D

func _ready():
	# Подключаем сигналы Area2D
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)


# Игрок вошел в зону взаимодействия
func _on_body_entered(body):
	if body.is_in_group("player"):  # Проверяем, что это игрок
		can_interact = true


# Игрок вышел из зоны
func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false


# Вызывается при нажатии E
func interact():
	save_game()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		Global.player_position = player.global_position
		Global.return_scene_path = get_tree().current_scene.scene_file_path  # <-- путь, не объект
	
	var cutscene_scene = load("res://scenes/memories/memory1.tscn")
	get_tree().change_scene_to_packed(cutscene_scene)


func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(player.position.x)
	file.store_var(player.position.y)
	
func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	player.position.x = file.get_var(player.position.x)
	player.position.y = file.get_var(player.position.y)

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		interact()
