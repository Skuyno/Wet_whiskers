extends Area2D

@onready var progress_bar = $ProgressBar

var progress: float = 0.0
var cat_in_zone: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	progress_bar.visible = false

func _process(delta):
	if cat_in_zone:
		progress += delta
		progress_bar.value = progress
		if progress >= 2.0:
			start_teleport()

func _on_body_entered(body):
	if body.name == "Cat":
		cat_in_zone = true
		progress_bar.visible = true
		progress = 0.0

func _on_body_exited(body):
	if body.name == "Cat":
		reset_progress()

func start_teleport():
	var cat = get_node("../../Cat")  # Или другой способ получить кота
	var target = get_node("../VentPortal4")
	
	if cat and target:
		# Анимация телепортации
		cat.global_position = target.global_position
	
	reset_progress()

func reset_progress():
	cat_in_zone = false
	progress = 0.0
	progress_bar.value = 0.0
	progress_bar.visible = false
