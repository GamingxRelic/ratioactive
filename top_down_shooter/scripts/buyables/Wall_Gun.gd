extends Node2D

@onready var buyable_component = $Buyable_Component
@onready var sprite : Sprite2D = $Sprite2D
@onready var text_label_component = $Text_Label_Component

@export var weapon_res : Weapon
@export var price : int

@onready var green_outline : ShaderMaterial = preload("res://assets/shaders/green_outline.tres")
@onready var white_outline : ShaderMaterial = preload("res://assets/shaders/white_outline.tres")

func _ready():
	buyable_component.price = price
	sprite.texture = weapon_res.texture
	sprite.material = green_outline
	text_label_component.set_text(str(price))

func _on_buyable_component_player_entered_range():
	text_label_component.show()
	sprite.material = white_outline

func _on_buyable_component_player_exited_range():
	text_label_component.hide()
	sprite.material = green_outline

func _on_buyable_component_purchased():
	for i in PlayerGun.weapons:
		if i.name == weapon_res.name and (i.total_ammo < i.max_ammo):# or i.ammo < i.clip_size):
			i.total_ammo = i.max_ammo
			i.ammo = i.clip_size
			PlayerGun.stop_reload.emit()
			return
	if PlayerGun.weapons.size() < PlayerGun.max_weapon_count:
		for i in PlayerGun.weapons:
			if i.name == weapon_res.name:
				#print("gun exists")
				return
		PlayerGun.weapons.append(weapon_res)
		PlayerGun.gun_added.emit()
		return
	print("error_wall_buy ", self)
