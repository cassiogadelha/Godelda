class_name UIPlayer
extends Control

@onready var heart_container: HBoxContainer = $Hearts/MarginContainer/HBoxContainer
@onready var spell_texture: TextureRect = $Spells/MarginContainer/TextureRect

var heart_scene: PackedScene = preload("res://Scenes/Player/heart.tscn")

var fire_texture: Texture2D = preload("res://Assets/graphics/ui/fire.png")
var heal_texture: Texture2D = preload("res://Assets/graphics/ui/heal.png")

func setup(value: int) -> void:
	for i: int in value:
		var heart: HeartPlayer = heart_scene.instantiate()
		heart_container.add_child(heart)
		heart.change_alpha(1.0)

		await get_tree().create_timer(0.3).timeout

func update_health(value: float, direction: int) -> void:
	for child: HeartPlayer in heart_container.get_children():
		child.queue_free()
		
	if direction < 0:
		for i: int in value:
			var heart: HeartPlayer = heart_scene.instantiate()
			heart_container.add_child(heart)
		var extra_heart: HeartPlayer = heart_scene.instantiate()
		heart_container.add_child(extra_heart)
		extra_heart.change_alpha(0.0)
	else:
		for i: int in value - 1:
			var heart: HeartPlayer = heart_scene.instantiate()
			heart_container.add_child(heart)
		var extra_heart: HeartPlayer = heart_scene.instantiate()
		heart_container.add_child(extra_heart)
		extra_heart.change_alpha(1.0)

func update_spells(spells: Dictionary, current_spell: int) -> void:
	if current_spell == spells.FIREBALL:
		spell_texture.texture = fire_texture
	else:
		spell_texture.texture = heal_texture