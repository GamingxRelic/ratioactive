extends Node2D

var player : CharacterBody2D
var player_pos : Vector2 
var player_hp 
var player_weapons : Array[Weapon]
var player_weapon_index : int
var player_gun : Weapon
var player_points : int
var add_points : int

var pickup_queue : Array

var UI : Control

var max_enemy_count : int
var enemy_count : int:
	get:
		return enemy_count
	set(value):
		enemy_count = value
		emit_signal("enemy_count_changed")
var enemy_spawn_queue : Array

signal next_wave
signal spawn_enemies
signal enemy_count_changed
