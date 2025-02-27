extends Level



func _on_area_3d_body_entered(_body: Node3D) -> void:
	call_deferred("switch_level", "overworld")
