extends Node2D
#@export var gun_res : Weapon = preload("res://resources/weapon/mini_pistol.tres")
@onready var fire_cooldown : Timer = $Fire_Cooldown
@onready var reload_timer : Timer = $Reload_Timer
@onready var sprite = $Sprite2D
@onready var gun_tip = $Gun_Tip
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var fire_particles : GPUParticles2D = $Firing_Particles
@onready var firing_light : PointLight2D = $Firing_Light
var bullet : PackedScene

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
	if PlayerGun.gun.ammo < PlayerGun.gun.clip_size and PlayerGun.gun.total_ammo > 0 and !is_reloading():
		can_reload = true
		
	if PlayerGun.gun.ammo == 0 and can_reload and !is_reloading():
		reload()
	
	firing_light.position = gun_tip.position
	
	if is_shooting:
		fire_particles.emitting = true
	else:
		fire_particles.emitting = false
		firing_light.energy = lerp(firing_light.energy, 0.0, 0.7)
	
func set_gun_res(res : Weapon):
	PlayerGun.gun = res
	bullet = res.bullet
	audio.stream = PlayerGun.gun.fire_sound
	fire_cooldown.wait_time = PlayerGun.gun.rate_of_fire
	sprite.texture = PlayerGun.gun.texture
	
	PlayerGun.gun.ammo = PlayerGun.weapons[PlayerGun.weapon_index].ammo
	PlayerGun.gun.total_ammo = PlayerGun.weapons[PlayerGun.weapon_index].total_ammo
	reload_timer.wait_time = PlayerGun.gun.reload_time
	
	firing_light.texture_scale = PlayerGun.gun.fire_flash_scale
	firing_light.color = PlayerGun.gun.fire_flash_color
	firing_light.energy = PlayerGun.gun.fire_flash_energy
	
	gun_tip.position = PlayerGun.gun.gun_tip_position
	position = PlayerGun.gun.position
	fire_particles.position = PlayerGun.gun.gun_tip_position
	
	#PlayerGun.gun.bullet_res.damage = PlayerGun.gun.damage

func flip_sprite():
	if global_rotation_degrees < -90 or global_rotation_degrees > 90:
		scale.y = -1
	else:
		scale.y = 1
	return

func fire():
	if can_fire and PlayerGun.gun.ammo > 0 and !reloading:
		audio.play()
		is_shooting = true
		fire_cooldown.start()
		
		
		$Firing_Light.energy = 1.0
		$Firing_Light.enabled = true
		
		var bullet_count
		if PlayerGun.gun.randomize_bullet_count:
			bullet_count = randi_range(PlayerGun.gun.randomized_bullet_count_min, PlayerGun.gun.randomized_bullet_count_max)
		else:
			bullet_count = PlayerGun.gun.bullet_count

		for i in bullet_count:
			var new_bullet = bullet.instantiate()
			new_bullet.global_position = gun_tip.global_position
			new_bullet.bullet_res = PlayerGun.gun.bullet_res
			new_bullet.aim_rotation_rad = rotation+randf_range(-PlayerGun.gun.bullet_spread,PlayerGun.gun.bullet_spread)
			get_node("/root/World").add_child(new_bullet)
			
		can_fire = false
		PlayerGun.gun.ammo -= 1
		return
	elif PlayerGun.gun.ammo == 0 and can_reload:
		reload()
	is_shooting = false
	return
	
func reload():
	if PlayerGun.gun.total_ammo <= 0 or PlayerGun.gun.ammo >= PlayerGun.gun.clip_size:
		return
	elif reload_timer.is_stopped():
		can_reload = false
		reloading = true
		reload_timer.start()
		reload_signal.emit()
	return
	
func _on_fire_cooldown_timeout():
	can_fire = true
	$Firing_Light.enabled = false
	return

func _on_reload_timer_timeout():
	if PlayerGun.gun.total_ammo-(PlayerGun.gun.clip_size-PlayerGun.gun.ammo) >= 0:
		PlayerGun.gun.total_ammo -= (PlayerGun.gun.clip_size-PlayerGun.gun.ammo)
		PlayerGun.gun.ammo = PlayerGun.gun.clip_size
		reloading = false
	elif PlayerGun.gun.total_ammo != 0:
		PlayerGun.gun.ammo += PlayerGun.gun.total_ammo
		PlayerGun.gun.total_ammo = 0
		reloading = false
	return

func is_reloading() -> bool:
	return true if reloading else false

func fill_ammo():
	PlayerGun.gun.ammo = PlayerGun.gun.clip_size
	PlayerGun.gun.total_ammo = PlayerGun.gun.max_ammo
