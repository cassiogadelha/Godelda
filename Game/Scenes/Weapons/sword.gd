extends Node3D

var can_damage : bool = false

func _process(_delta: float) -> void:
	if can_damage:
		var collider: CollisionShape3D = $RayCast3D.get_collider()
		if collider and 'hit' in collider:
			collider.hit()
