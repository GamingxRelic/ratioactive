extends Node2D


var weapon_res : Weapon
var price : int
@onready var sprite : Sprite2D = $Sprite2D
@onready var text_label_component = $Text_Label_Component
@onready var buyable_component = $Buyable_Component
@onready var anim : AnimationPlayer = $AnimationPlayer

var cleared := false

func _ready() -> void:
	set_weapon()
	World.cantuna_cycle_weapon.connect(_on_cantuna_cycle_weapon)
	
func set_weapon() -> void:
	weapon_res = WeaponList.get_random_weapon()
	sprite.texture = weapon_res.texture
	price = weapon_res.cantuna_price
	buyable_component.price = price
	text_label_component.set_text("[E] - " + weapon_res.name + "\n$" +str(price))
	
	buyable_component.monitoring = true
	buyable_component.monitorable = true
	self.visible = true

func _on_buyable_component_player_entered_range():
	text_label_component.show()
	sprite.material = World.outline

func _on_buyable_component_player_exited_range():
	text_label_component.hide()
	sprite.material = null

func _on_cantuna_cycle_weapon() -> void:
	anim.play("fade_out")

func _on_buyable_component_purchased():
	for i in PlayerGun.weapons:
		if i.name == weapon_res.name and (i.total_ammo < i.max_ammo):
			i.total_ammo = i.max_ammo
			World.kaching_sound.emit()
			PlayerGun.stop_reload.emit()
			clear()
			return
		elif i.name == weapon_res.name and (i.total_ammo >= i.max_ammo):
			buyable_component.refund()
			return
	if PlayerGun.weapons.size() < PlayerGun.max_weapon_count:
		for i in PlayerGun.weapons:
			if i.name == weapon_res.name:
				buyable_component.refund()
				return
		World.kaching_sound.emit()
		PlayerGun.weapons.append(weapon_res.duplicate())
		PlayerGun.gun_added.emit()
		clear()
		return
	else:
		buyable_component.refund()
		return


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		set_weapon()
		anim.play("fade_in")

func clear() -> void:
	buyable_component.monitoring = false
	buyable_component.monitorable = false
	self.visible = false
