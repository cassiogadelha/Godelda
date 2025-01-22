extends Node3D

var fireball_scene: PackedScene = preload("res://Scenes/VFX/fire_ball.tscn")

func _ready() -> void:
    for entity in $Entities.get_children():
        if entity.has_signal("cast_spell"):
            entity.connect("cast_spell", create_fireball)

func create_fireball(_type:String, _pos:Vector3, _direction:Vector2, _size:float) -> void:
    var fireball = fireball_scene.instantiate() as Fireball
    $Projectiles.add_child(fireball)

    fireball.global_position = _pos
    fireball.direction = _direction
    fireball.setup(_size)
    
