extends Node2D
#@export var gun_res : Weapon = preload("res://resources/weapon/mini_pistol.tres")
@onready var fire_cooldown : Timer = $Fire_Cooldown
@onready var reload_timer : Timer = $Reload_Timer
@onready var sprite = $Sprite2D
@onready var gun_tip = $Gun_Tip
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var fire_particles : GPUParticles2D = $Firing_Particles
var bullet = preload("res://scenes/Bullet.tscn")

var mouse_pos
var can_fire := true
var can_reload := false
var reloading := false
var is_shooting := false

signal reload_signal


func _physics_process(_delta):
	mouse_pos = get_global_mouse_position()
	look_at(get_global_mouse_position())
	flip_sprite()
	if World.player_gun.ammo < World.player_gun.clip_size and World.player_gun.total_ammo > 0:
		can_reload = true
		
	if World.player_gun.ammo == 0 and can_reload and !is_reloading():
		reload()
		
	if is_shooting:
		fire_particles.emitting = true
	else:
		fire_particles.emitting = false
	
func set_gun_res(res : Weapon):
	World.player_gun = res
	audio.stream = World.player_gun.fire_sound
	fire_cooldown.wait_time = World.player_gun.rate_of_fire
	sprite.texture = World.player_gun.texture
	
	World.player_gun.ammo = World.player_weapons[World.player_weapon_index].ammo
	World.player_gun.total_ammo = World.player_weapons[World.player_weapon_index].total_ammo
	reload_timer.wait_time = World.player_gun.reload_time
	
	gun_tip.position = World.player_gun.gun_tip_position
	position = World.player_gun.position
	fire_particles.position = World.player_gun.gun_tip_position
	
	World.player_gun.bullet_res.damage = World.player_gun.damage
	
	

func flip_sprite():
	if global_rotation_degrees < -90 or global_rotation_degrees > 90:
		scale.y = -1
	else:
		scale.y = 1
	return

func fire():
	if can_fire and World.player_gun.ammo > 0 and !reloading:
		audio.play()
		is_shooting = true
		fire_cooldown.start()
		for i in World.player_gun.bullet_count:
			var new_bullet = bullet.instantiate()
			new_bullet.global_position = gun_tip.global_position
			new_bullet.bullet_res = World.player_gun.bullet_res
			new_bullet.aim_rotation_rad = rotation+randf_range(-World.player_gun.bullet_spread,World.player_gun.bullet_spread)
			get_node("/root/World").add_child(new_bullet)
		can_fire = false
		World.player_gun.ammo -= 1
		return
	elif World.player_gun.ammo == 0 and can_reload:
		reload()
	is_shooting = false
	return
	
func reload():
	if World.player_gun.total_ammo == 0 or World.player_gun.ammo == World.player_gun.clip_size:
		return
	elif reload_timer.is_stopped():
		reloading = true
		reload_timer.start()
		reload_signal.emit()
	return
	
func _on_fire_cooldown_timeout():
	can_fire = true
	return

func _on_reload_timer_timeout():
	if World.player_gun.total_ammo-(World.player_gun.clip_size-World.player_gun.ammo) >= 0:
		World.player_gun.total_ammo -= (World.player_gun.clip_size-World.player_gun.ammo)
		World.player_gun.ammo = World.player_gun.clip_size
		reloading = false
	elif World.player_gun.total_ammo != 0:
		World.player_gun.ammo += World.player_gun.total_ammo
		World.player_gun.total_ammo = 0
		reloading = false
	return

func is_reloading() -> bool:
	return true if reloading else false

func fill_ammo():
	World.player_gun.ammo = World.player_gun.clip_size
	World.player_gun.total_ammo = World.player_gun.max_ammo
