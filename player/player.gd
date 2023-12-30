extends CharacterBody2D

signal life_changed
signal died

@export var life = 3: set = set_life
func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(STATE.DEAD)

@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -300

enum STATE {IDLE, RUN, JUMP, HURT, DEAD}

var state: STATE = STATE.IDLE

func _ready() -> void:
	change_state(STATE.IDLE)


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	get_input(delta)
	move_and_slide()
	if state == STATE.HURT:
		return
	for i in get_slide_collision_count():
		var collision =get_slide_collision(i)
		if collision.get_collider().is_in_group("danger"):
			hurt()
	if state == STATE.JUMP and is_on_floor():
		change_state(STATE.IDLE)
	if state == STATE.JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")


func change_state(new_state: STATE) -> void:
	state = new_state
	match state:
		STATE.IDLE:
			$AnimationPlayer.play("idle")
		STATE.RUN:
			$AnimationPlayer.play("run")
		STATE.HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(STATE.IDLE)
		STATE.JUMP:
			$AnimationPlayer.play("jump_up")
		STATE.DEAD:
			died.emit()
			hide()


func get_input(delta):
	if state == STATE.HURT:
		return
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_pressed("jump")
	#movement occurs in all states
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	#only allow jumping when on the ground
	if jump and is_on_floor():
		change_state(STATE.JUMP)
		velocity.y = jump_speed
	if is_on_wall():
		velocity.y = 10
	if is_on_wall_only() and Input.is_action_pressed("jump"):
		if right:
			velocity.x = -jump_speed
		else:
			velocity.x = jump_speed
		velocity.y = jump_speed
		
	#IDLE transitions to RUN when moving
	if state == STATE.IDLE and velocity.x != 0:
		change_state(STATE.RUN)
	# RUN transitions to IDLE when stending still
	if state == STATE.RUN and velocity.x == 0:
		change_state(STATE.IDLE)
	# transitions to JUMP when it the air
	if state in [STATE.IDLE, STATE.RUN] and !is_on_floor():
		change_state(STATE.JUMP)


func reset(_position):
	position = _position
	show()
	change_state(STATE.IDLE)
	life = 3


func hurt():
	if state != STATE.HURT:
		change_state(STATE.HURT)
