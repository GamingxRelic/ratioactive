extends Node2D

@onready var buyable_component = $Buyable_Component
@onready var sprite : Sprite2D = $Sprite2D
@onready var text_label_component = $Text_Label_Component

@export var weapon_res : Weapon
@export var price : int

func _ready():
	buyable_component.price = price
	sprite.texture = weapon_res.texture
	sprite.material = World.green_outline
	text_label_component.set_text("[E] - " + weapon_res.name + "\n$" +str(price))

func _on_buyable_component_player_entered_range():
	text_label_component.show()
	sprite.material = World.white_outline

func _on_buyable_component_player_exited_range():
	text_label_component.hide()
	sprite.material = World.green_outline

func _on_buyable_component_purchased():
	for i in PlayerGun.weapons:
		if i.name == weapon_res.name and (i.total_ammo < i.max_ammo):# or i.ammo < i.clip_size):
			i.total_ammo = i.max_ammo
			#i.ammo = i.clip_size # This is for filling the magazine as well.
			PlayerGun.stop_reload.emit()
			World.kaching_sound.emit()
			return
		elif i.name == weapon_res.name and (i.total_ammo >= i.max_ammo):
			buyable_component.refund()
			return
	if PlayerGun.weapons.size() < PlayerGun.max_weapon_count:
		for i in PlayerGun.weapons:
			if i.name == weapon_res.name:
				#print("gun exists")
				return
		World.kaching_sound.emit()
		PlayerGun.weapons.append(weapon_res.duplicate())
		PlayerGun.gun_added.emit()
		return
	
	print("error_wall_buy ", self)
