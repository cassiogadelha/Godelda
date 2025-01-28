class_name Level
extends Node3D

var fireball_scene: PackedScene = preload("res://Scenes/VFX/fire_ball.tscn")

const scenes: Dictionary = {
    'dungeon': "res://Scenes/Level/dungeon.tscn",
    'overworld': "res://Scenes/Level/overworld.tscn",
}

func _ready() -> void:
    for entity: Node3D in $Entities.get_children():
        if entity.has_signal("cast_spell"):
            entity.connect("cast_spell", create_fireball)

func create_fireball(_type:String, _pos:Vector3, _direction:Vector2, _size:float) -> void:
    var fireball: Fireball = fireball_scene.instantiate()
    $Projectiles.add_child(fireball)

    fireball.global_position = _pos
    fireball.direction = _direction
    fireball.setup(_size)
    
func switch_level(level_name: String) -> void:
    get_tree().change_scene_to_file(scenes[level_name])