extends Camera2D

var shake_intensity: float = 0.0
var decay_rate: float = 2.0

func _process(delta):
	shake_intensity = lerp(shake_intensity, 0.0, delta * decay_rate)
	offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)

func add_shake(intensity: float):
	shake_intensity += intensity
