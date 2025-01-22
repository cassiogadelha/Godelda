extends Enemy

func _physics_process(delta: float) -> void:
    move_to_player(delta)


func _on_attack_timer_timeout() -> void:
    $Timers/AttackTimer.wait_time = rng.randf_range(2.0, 3.0)

    if position.distance_to(player.position) < attack_radius:
        $AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shoot_fireball() -> void:
    var _direction: Vector3= (player.position - position).normalized()
    var _direction_2d := Vector2(_direction.x, _direction.z)

    var _position: Vector3 = $Skin/Rig/Skeleton3D/BoneAttachment3D/wand2/wand/MagicSpawnPoint.global_position
    cast_spell.emit('fireball', _position, _direction_2d, 1.0)