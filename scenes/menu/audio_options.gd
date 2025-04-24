extends Control


@onready var music_slider = $HSlider  # путь до твоего слайдера

func _ready():
	# Установить начальное значение слайдера по текущей громкости
	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	music_slider.value_changed.connect(_on_h_slider_value_changed)


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
