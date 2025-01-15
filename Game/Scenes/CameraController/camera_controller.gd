extends Node3D

@export var min_limit_x: float
@export var max_limit_x: float

@export var mouse_acceleration := 0.005

func _input(event: InputEvent) ->  void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * mouse_acceleration)

func rotate_from_vector(vector: Vector2):
	if vector.length() == 0: return

	rotation.y -= vector.x #subtrai porque tem player que gosta de inverter o controle da camera com a entrada de input
	rotation.x -= vector.y

	rotation.x = clamp(rotation.x, min_limit_x, max_limit_x)
