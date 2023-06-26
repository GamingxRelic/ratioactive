extends Resource
class_name Weapon

@export var rate_of_fire : float
@export var damage : float
@export var weapon_name : String
@export var texture : Texture

@export var position : Vector2
@export var gun_tip_position : Vector2 

@export var bullet_res : Bullet

@export var fire_sound : AudioStream

var ammo : int
var total_ammo : int
@export var clip_size : int
@export var max_ammo : int

@export var reload_time : float
