extends Area2D

@export var weapon_res : Weapon
@onready var sprite : Sprite2D = $Sprite2D
@onready var text_label_comp : Control = $Text_Label_Component

var player_in_range := false

func _ready() -> void:
	set_weapon()
	text_label_comp.set_label_settings(preload("res://resources/labels/Dropped_Weapons_Label.tres"))

#func _process(_delta) -> void:
	#if Input.is_action_just_pressed("interact") and player_in_range and PlayerGun.weapons.size() < 5:
	#	pickup()

func set_weapon() -> void:
	sprite.texture = weapon_res.texture
	text_label_comp.set_text("[E] " + weapon_res.name)

func pickup() -> void:
	for i in PlayerGun.weapons:
		if i.name == World.pickup_queue[0].weapon_res.name:
			var remaining_ammo : int = World.pickup_queue[0].weapon_res.total_ammo + World.pickup_queue[0].weapon_res.ammo
			if i.total_ammo < i.max_ammo:
				i.total_ammo = clampi(i.total_ammo + remaining_ammo, 0, i.max_ammo)
				World.pickup_queue.remove_at(0)
				queue_free()
				return
			return
	if PlayerGun.weapons.size() < PlayerGun.max_weapon_count:
		PlayerGun.weapons.append(weapon_res.duplicate())
		PlayerGun.gun_added.emit()
		World.pickup_queue.remove_at(0)
		queue_free()
		return
	return

func _on_area_entered(area) -> void:
	if area.is_in_group("player"):
		player_in_range = true
		World.pickup_queue.append(self)

func _on_area_exited(area) -> void:
	if area.is_in_group("player"):
		player_in_range = false
		World.pickup_queue.erase(self)
