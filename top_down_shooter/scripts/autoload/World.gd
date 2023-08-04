extends Node2D

var outline : ShaderMaterial = preload("res://assets/shaders/outline.tres")
var yellow_outline : ShaderMaterial = preload("res://assets/shaders/yellow_outline.tres")
var green_outline : ShaderMaterial = preload("res://assets/shaders/green_outline.tres")
var white_outline : ShaderMaterial = preload("res://assets/shaders/white_outline.tres")

var player : CharacterBody2D
var player_pos : Vector2 
var player_hp
var player_hurtbox : Area2D
var player_points : int
var add_points : int

var pickup_queue : Array

var UI : Control

var wave : int

var max_enemy_count : int
var enemy_count : int:
	get:
		return enemy_count
	set(value):
		enemy_count = value
		emit_signal("enemy_count_changed")
#var enemy_spawn_queue : Array
var total_wave_enemies_spawned : int
var max_wave_enemy_count : int
var remaining_wave_enemy_count : int:
	get:
		return remaining_wave_enemy_count
	set(value):
		remaining_wave_enemy_count = value
		emit_signal("remaining_wave_enemy_count_changed")

signal next_wave
signal spawn_enemies
signal enemy_count_changed
signal remaining_wave_enemy_count_changed
signal kill_all_enemies
signal player_death
signal cantuna_cycle_weapon
