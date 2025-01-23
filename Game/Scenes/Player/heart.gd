class_name HeartPlayer
extends TextureRect

func change_alpha(target: float) -> void:
    var tween: Tween = create_tween()
    tween.tween_method(_change_alpha, 1.0 - target, target, 0.4)

func _change_alpha(value: float) -> void:
    material.set_shader_parameter('alpha', value)
    material.set_shader_parameter('progress', 1.0 - value)