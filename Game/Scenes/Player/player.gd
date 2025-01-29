class_name Player
extends CharacterBody3D

#jump
@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3 

@onready var run_particle: GPUParticles3D = $RunParticles

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))
#source youtu.be/I0e1aGY6hXA?feature=shared

@export var base_speed : float = 4.0
@export var run_speed : float = 6.0
@export var defend_speed : float = 2.0

@onready var camera : Camera3D = $CameraController/Camera3D
@onready var godette_skin : GodetteSkin = $GodetteSkin
@onready var ui: UIPlayer = $UI
@onready var invul_timer: Timer = $Timers/InvulTimer

enum spells{
	FIREBALL,
	HEAL
}
var current_spell: spells = spells.FIREBALL

var health: int = 5:
	set(value):
		ui.update_health(value, value - health)
		health = value
		if health <= 0:
			get_tree().quit()

var energy: int = 100:
	set(value):
		energy = value
		ui.update_energy(min(100, value))

var stamina: int = 100:
	set(value):
		ui.update_stamina(stamina, min(100, value))
		
		if stamina == 100 and value < 100:
			ui.change_stamina_alpha(1.0)

		if value == 100:
			ui.change_stamina_alpha(0.0)

		stamina = clamp(value, 0, 100)

signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)

var speed_modifier : float = 1.0

var movement_input : Vector2 = Vector2.ZERO
var last_movement_input : Vector2 = Vector2(0, 1)

var weapon_active : bool = true:
	set(value):
		weapon_active = value
		if weapon_active:
			ui.get_node("Spells").hide()
		else:
			ui.get_node("Spells").show()

var defend : bool = false:
	set(value):
		if not defend and value:
			godette_skin.defend(true)
		if defend and not value:
			godette_skin.defend(false)
		defend = value

func _ready() -> void:
	ui.setup(health)

func _physics_process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("player_position", global_position)

	move_logic(delta)
	jump_logic(delta)
	ability_logic()	
	move_and_slide()
	physics_logic()

func move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)

	var is_running : bool = Input.is_action_pressed("run")

	var velocity_2d : Vector2 = Vector2(velocity.x, velocity.z)

	if movement_input != Vector2.ZERO:
		var speed : float = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed

		velocity_2d += movement_input * speed * delta *  10.0
		velocity_2d = velocity_2d.limit_length(speed) * speed_modifier

		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y

		godette_skin.set_move_state("Running")

		#rotação do player com a camera
		var target_angle : float = -movement_input.angle() + PI / 2
		$GodetteSkin.rotation.y = rotate_toward($GodetteSkin.rotation.y, target_angle, 10.0 * delta)


	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, base_speed * 6.0 * delta)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
		godette_skin.set_move_state("Idle")

	if movement_input:
		last_movement_input = movement_input.normalized()

	run_particle.emitting = is_on_floor() and is_running and movement_input != Vector2.ZERO

	if is_on_floor() and movement_input:
		if not $Sounds/StepSound.playing:
			$Sounds/StepSound.playing = true
	else:
		$Sounds/StepSound.playing = false

func jump_logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and stamina >= 20:
			velocity.y = -jump_velocity
			do_squash_and_stretch(1.2, 0.15)
			godette_skin.set_move_state("Jump")
			stamina -= 20

	else:
		godette_skin.set_move_state("Idle")

		var gravity : float = jump_gravity if velocity.y > 0.0 else fall_gravity

		velocity.y += gravity * delta

func ability_logic() -> void:
	if Input.is_action_just_pressed("ability"):
		if weapon_active and stamina >= 5:
			stamina -= 5
			godette_skin.attack()
			$Sounds/SwordSound.play()
		else:
			if energy >= 20:
				godette_skin.cast_spell()
				stop_movement(0.3, 0.8)
				energy -= 20

	defend = Input.is_action_pressed("block")

	if Input.is_action_just_pressed("switch weapon") and not godette_skin.attacking:
		weapon_active = not weapon_active
		godette_skin.switch_weapon(weapon_active)
		do_squash_and_stretch(1.2, 0.15)

	if Input.is_action_just_pressed("switch spell") and not godette_skin.attacking:
		current_spell = spells[spells.keys()[(int(current_spell) + 1) % len(spells)]]
		ui.update_spells(spells, current_spell)


func stop_movement(start_duration: float, end_duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func hit() -> void:
	if not invul_timer.time_left:
		godette_skin.hit()
		stop_movement(0.3, 0.3)
		health -= 1

		invul_timer.start()

func do_squash_and_stretch(value: float, duration: float = 0.1) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(godette_skin, "squash_and_stretch", value, duration)
	tween.tween_property(godette_skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(tween.EASE_OUT)

func shoot_magic(pos: Vector3) -> void:
	if current_spell == spells.FIREBALL:
		cast_spell.emit("fireball", pos, last_movement_input, 1.0)
	else:
		health += 1
		godette_skin.heal_tween()


func _on_energy_recovery_timer_timeout() -> void:
	energy += 1


func _on_stamina_recovery_timer_timeout() -> void:
	stamina += 1

func physics_logic() -> void:
	for i: int in get_slide_collision_count():
		var collider: Object = get_slide_collision(i).get_collider()
		if collider is RigidBody3D:
			collider.apply_central_impulse(-get_slide_collision(i).get_normal())
