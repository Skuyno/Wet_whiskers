extends AnimatedSprite2D

enum State {IDLE, NERVOUS, ATTACKING, GATHERING}
var speed = 300;
var gather_speed = 100
var current_state = State.IDLE
var target: Node2D
var bread_position: Vector2

func start_attack(cat: Node2D):
	if current_state != State.GATHERING:
		target = cat
		current_state = State.ATTACKING
		play("attack")
		# Логика преследования кота

func start_gathering(pos: Vector2):
	current_state = State.GATHERING
	bread_position = pos
	play("gather")
	# Логика движения к хлебу

func return_to_idle():
	if current_state != State.GATHERING:
		current_state = State.IDLE
		play("idle")

func _process(delta):
	match current_state:
		State.ATTACKING:
			if target:
				position += (target.global_position - global_position).normalized() * speed * delta
		State.GATHERING:
			position += (bread_position - global_position).normalized() * gather_speed * delta
