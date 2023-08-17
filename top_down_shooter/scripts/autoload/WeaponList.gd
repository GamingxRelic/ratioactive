extends Node2D

var list : Array[Weapon] = [
#preload("res://resources/weapon/ak-47.tres"), # Wall gun
preload("res://resources/weapon/mini_pistol.tres"),
#preload("res://resources/weapon/pewpew.tres"), # Wall gun
preload("res://resources/weapon/ruahil.tres"),
#preload("res://resources/weapon/sawed_off.tres"), # Wall gun
preload("res://resources/weapon/sniper.tres"),
preload("res://resources/weapon/snake_gun.tres"),
preload("res://resources/weapon/pencil.tres"),
preload("res://resources/weapon/chimkin.tres"),
preload("res://resources/weapon/fish_barrel.tres"),
preload("res://resources/weapon/cheese_square.tres"),
preload("res://resources/weapon/rat_gun.tres")
]

func get_random_weapon() -> Weapon:
	return list[randi_range(0,list.size()-1)].duplicate()
