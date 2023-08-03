extends Node2D

var weapons : Array[Weapon]
var weapon_index : int
var gun : Weapon

var max_weapon_count : int = 6

signal stop_reload
signal gun_added
