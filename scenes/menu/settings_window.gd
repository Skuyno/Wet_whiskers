extends PopupPanel

@onready var music_slider = $VBoxContainer/HBoxContainer/HSlider  # путь до твоего слайдера

func _ready():
	# Установить начальное значение слайдера по текущей громкости
	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds"))
	music_slider.value_changed.connect(_on_music_slider_value_changed)

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), value)
