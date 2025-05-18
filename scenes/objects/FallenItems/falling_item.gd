extends RigidBody2D

func _ready():
	gravity_scale = 0.1
	linear_velocity = Vector2(0, 30)

	# Подключаем сигнал от дочерней Area2D
	$Area2D.connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	if area.is_in_group("delete_zone"):
		queue_free()
