extends Node2D

var weapons : Array[Weapon]
var weapon_index : int
var gun : Weapon

var max_weapon_count : int = 6

var infinite_ammo := false

func reset() -> void:
	weapons = []
	weapon_index = 0
	gun = null
	infinite_ammo = false

signal stop_reload
signal gun_added
