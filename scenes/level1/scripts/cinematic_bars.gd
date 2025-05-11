extends CanvasLayer

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar

func animate_in():
	var tween = create_tween().set_parallel()
	tween.tween_property(top_bar, "position:y", 0, 0.8).from_current()
	tween.tween_property(bottom_bar, "position:y", 560, 0.8).from_current()
	tween.tween_property(top_bar, "color:a", 0.9, 0.5)
	tween.tween_property(bottom_bar, "color:a", 0.9, 0.5)

func animate_out():
	var tween = create_tween().set_parallel()
	tween.tween_property(top_bar, "position:y", -100, 0.8)
	tween.tween_property(bottom_bar, "position:y", 720, 0.8)
