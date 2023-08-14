extends Node2D

var list : Array[Weapon] = [
preload("res://resources/weapon/ak-47.tres"),
preload("res://resources/weapon/mini_pistol.tres"),
preload("res://resources/weapon/pewpew.tres"),
preload("res://resources/weapon/ruahil.tres"),
preload("res://resources/weapon/sawed_off.tres"),
preload("res://resources/weapon/sniper.tres")
]
#preload(),

func get_random_weapon() -> Weapon:
	return list[randi_range(0,list.size()-1)].duplicate()
