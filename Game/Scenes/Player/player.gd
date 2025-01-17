class_name Player
extends CharacterBody3D

#jump
@export var jump_height := 2.25
@export var jump_time_to_peak := 0.4
@export var jump_time_to_descent := 0.3 

@onready var jump_velocity := ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity := ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity := ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))
#source youtu.be/I0e1aGY6hXA?feature=shared

@export var base_speed := 4.0
@export var run_speed := 6.0
@export var defend_speed := 2.0

@onready var camera = $CameraController/Camera3D
@onready var godette_skin = $GodetteSkin

var speed_modifier := 1.0

var movement_input := Vector2.ZERO

var weapon_active := true


var defend := false:
	set(value):
		if not defend and value:
			godette_skin.defend(true)
		if defend and not value:
			godette_skin.defend(false)
		defend = value

func _physics_process(delta) -> void:

	move_logic(delta)
	jump_logic(delta)
	ability_logic()

	if Input.is_action_just_pressed("ui_accept"):
		hit()
	
	move_and_slide()

func move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)

	var is_running := Input.is_action_pressed("run")

	var velocity_2d := Vector2(velocity.x, velocity.z)

	if movement_input != Vector2.ZERO:
		var speed := run_speed if is_running else base_speed
		speed = defend_speed if defend else speed

		velocity_2d += movement_input * speed * delta *  10.0
		velocity_2d = velocity_2d.limit_length(speed) * speed_modifier

		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y

		godette_skin.set_move_state("Running")

		#rotação do player com a camera
		var target_angle := -movement_input.angle() + PI / 2
		$GodetteSkin.rotation.y = rotate_toward($GodetteSkin.rotation.y, target_angle, 10.0 * delta)


	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, base_speed * 6.0 * delta)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
		godette_skin.set_move_state("Idle")

func jump_logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
			do_squash_and_stretch(1.2, 0.15)
			godette_skin.set_move_state("Jump")

	else:
		godette_skin.set_move_state("Idle")

	var gravity := jump_gravity if velocity.y > 0.0 else fall_gravity

	velocity.y += gravity * delta

func ability_logic() -> void:
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			godette_skin.attack()
		else:
			godette_skin.cast_spell()
			stop_movement(0.3, 0.8)

	defend = Input.is_action_pressed("block")

	if Input.is_action_just_pressed("switch weapon") and not godette_skin.attacking:
		weapon_active = not weapon_active
		godette_skin.switch_weapon(weapon_active)
		do_squash_and_stretch(1.2, 0.15)

func stop_movement(start_duration: float, end_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func hit() -> void:
	godette_skin.hit()
	stop_movement(0.3, 0.3)

func do_squash_and_stretch(value: float, duration: float = 0.1):
	var tween = create_tween()
	tween.tween_property(godette_skin, "squash_and_stretch", value, duration)
	tween.tween_property(godette_skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(tween.EASE_OUT)
