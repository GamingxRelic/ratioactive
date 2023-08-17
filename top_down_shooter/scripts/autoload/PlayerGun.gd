extends Node2D

var weapons : Array[Weapon]
var weapon_index : int
var gun : Weapon

var max_weapon_count : int = 6

var infinite_ammo := false

func fill_all_ammo() -> void:
	if weapons.size() > 0:
		for i in weapons:
			i.total_ammo = i.max_ammo
		ammo_filled.emit()
	return
	
func reset() -> void:
	weapons = []
	weapon_index = 0
	gun = null
	infinite_ammo = false
	return

signal stop_reload
signal gun_added
signal ammo_filled
