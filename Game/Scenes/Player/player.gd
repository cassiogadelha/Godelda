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

@onready var camera = $CameraController/Camera3D

var movement_input := Vector2.ZERO

func _physics_process(delta) -> void:

	move_logic(delta)
	jump_logic(delta)
	
	move_and_slide()

func move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)

	var is_running := Input.is_action_pressed("run")

	var velocity_2d := Vector2(velocity.x, velocity.z)

	if movement_input != Vector2.ZERO:
		var speed := run_speed if is_running else base_speed

		velocity_2d += movement_input * speed * delta
		velocity_2d = velocity_2d.limit_length(speed)

		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y

	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y

func jump_logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity

	var gravity := jump_gravity if velocity.y > 0.0 else fall_gravity

	velocity.y += gravity * delta


