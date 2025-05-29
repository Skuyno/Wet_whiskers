extends Node2D

func _ready() -> void:
	$UI/BlackSquare.visible = true
	$Sounds/Rain.play()
	create_fade_tween_outside(3.0)
	$Cat/AnimatedSprite2D.play("walk")
	$AnimationPlayer.play("walk")
	await $AnimationPlayer.animation_finished
	$Cat/AnimatedSprite2D.play("idle")
	await get_tree().create_timer(5.0).timeout
	$AnimationPlayer.play("girlishka_walk")
	$Girlishka/AnimatedSprite2D.play("walk")
	await $AnimationPlayer.animation_finished
	$Girlishka/AnimatedSprite2D.play("idle")
	await get_tree().create_timer(1.0).timeout
	$Cat/AnimatedSprite2D.play("lick")
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("girlishka_walk2")
	$Girlishka/AnimatedSprite2D.play("walk")
	await $AnimationPlayer.animation_finished
	$Girlishka/AnimatedSprite2D.play("idle")
	$Cat/AnimatedSprite2D.flip_h = true
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("cat_walk2")
	$Cat/AnimatedSprite2D.play("walk")
	await $AnimationPlayer.animation_finished
	$Cat/AnimatedSprite2D.play("idle")
	await get_tree().create_timer(1.0).timeout
	$Cat/AnimatedSprite2D.play("walk")
	$Girlishka/AnimatedSprite2D.play("walk")
	$AnimationPlayer.play("cat_walk3")
	await get_tree().create_timer(4.0).timeout
	create_fade_out_tween_outside(3.0)

func create_fade_tween_outside(duration: float):
	var tween = create_tween().set_parallel(true)
	
	# Анимация звуков
	tween.tween_method(set_audio_volume_rain_outside.bind(), -30.0, 0.0, duration)
	
	# Анимация затемнения экрана
	tween.tween_property($UI/BlackSquare, "color:a", 0.0, duration)\
		 .set_ease(Tween.EASE_IN_OUT)\
		 .set_trans(Tween.TRANS_SINE)
		
func create_fade_out_tween_outside(duration: float):
	var tween = create_tween().set_parallel(true)
	
	# Анимация затухания звуков
	tween.tween_method(set_audio_volume_rain_outside.bind(), 0.0, -30.0, duration)
	
	# Анимация затемнения экрана
	tween.tween_property($UI/BlackSquare, "color:a", 1.0, duration)\
		 .set_ease(Tween.EASE_IN_OUT)\
		 .set_trans(Tween.TRANS_SINE)

func set_audio_volume_rain_outside(db: float):
	$Sounds/Rain.volume_db = db
