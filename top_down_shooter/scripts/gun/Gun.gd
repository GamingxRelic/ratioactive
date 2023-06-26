extends Node2D
@export var gun_res : Weapon = preload("res://resources/weapon/mini_pistol.tres")
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


func _ready():
	audio.stream = gun_res.fire_sound
	fire_cooldown.wait_time = gun_res.rate_of_fire
	sprite.texture = gun_res.texture
	
	gun_res.ammo = gun_res.clip_size
	gun_res.total_ammo = gun_res.max_ammo
	reload_timer.wait_time = gun_res.reload_time
	
	gun_tip.position = gun_res.gun_tip_position
	position = gun_res.position
	fire_particles.position = gun_res.gun_tip_position
	
	gun_res.bullet_res.damage = gun_res.damage

func _physics_process(_delta):
	mouse_pos = get_global_mouse_position()
	look_at(get_global_mouse_position())
	flip_sprite()
	if gun_res.ammo < gun_res.clip_size and gun_res.total_ammo > 0:
		can_reload = true
	
	

func flip_sprite():
	if global_rotation_degrees < -90 or global_rotation_degrees > 90:
		scale.y = -1
	else:
		scale.y = 1

func fire():
	if can_fire and gun_res.ammo > 0 and !reloading:
		audio.play()
		fire_particles.emitting = true
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = gun_tip.global_position
		new_bullet.bullet_res = gun_res.bullet_res
		new_bullet.aim_rotation_rad = rotation
		get_node("/root/World").add_child(new_bullet)
		can_fire = false
		gun_res.ammo -= 1
		fire_cooldown.start()
	elif gun_res.ammo == 0 and can_reload:
		reload()
	
func reload():
	if reload_timer.is_stopped():
		reloading = true
		reload_timer.start()
		print("bag")
	
func _on_fire_cooldown_timeout():
	can_fire = true

func _on_reload_timer_timeout():
	#this needs to be fixed
	var amount_reloaded = gun_res.clip_size if gun_res.total_ammo >= gun_res.clip_size else gun_res.total_ammo 
	gun_res.total_ammo -= amount_reloaded-gun_res.ammo
	gun_res.ammo = amount_reloaded
	reloading = false
