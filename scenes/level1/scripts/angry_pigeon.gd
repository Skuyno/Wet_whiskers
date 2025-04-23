# Pigeon.gd
extends AnimatedSprite2D

enum State {IDLE, NERVOUS, ATTACKING, GATHERING}
var current_state = State.IDLE
var speed = 300
var target: Node2D
var bread_pos: Vector2
var attack_timer: Timer

func start_attack(cat: Node2D):
	if current_state != State.GATHERING:
		current_state = State.ATTACKING
		target = cat
		play("attack")
		attack_timer = Timer.new()
		attack_timer.name = "AttackTimer"
		attack_timer.one_shot = true
		add_child(attack_timer)
		attack_timer.start(3.0)

func start_gathering(pos: Vector2):
	current_state = State.GATHERING
	bread_pos = pos

func _process(delta):
	match current_state:
		State.ATTACKING:
			if target:
				var dir = (target.global_position - global_position).normalized()
				position += dir * speed * delta
				flip_h = dir.x < 0
		State.GATHERING:
			var dir = (bread_pos - global_position).normalized()
			position += dir * speed * delta
			flip_h = dir.x < 0
