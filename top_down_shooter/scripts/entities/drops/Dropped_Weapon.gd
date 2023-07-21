extends Area2D

@export var weapon_res : Weapon
@onready var sprite : Sprite2D = $Sprite2D
@onready var text_label_comp : Control = $Text_Label_Component

var player_in_range := false

func _ready() -> void:
	set_weapon()
	text_label_comp.set_label_settings(preload("res://resources/labels/Dropped_Weapons_Label.tres"))
	
	
func _process(_delta) -> void:
	if Input.is_action_just_pressed("interact") and player_in_range and World.player_weapons.size() < 5:
		pickup()

func set_weapon() -> void:
	sprite.texture = weapon_res.texture
	text_label_comp.set_text("[E] " + weapon_res.name)
	

func pickup() -> void:
	World.player_weapons.append(weapon_res)
	World.player.select_weapon(World.player_weapons.size()-1)
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		player_in_range = true

func _on_area_exited(area):
	if area.is_in_group("player"):
		player_in_range = false
