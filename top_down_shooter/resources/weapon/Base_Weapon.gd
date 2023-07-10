extends Resource
class_name Weapon

@export var rate_of_fire : float
@export var damage : float
@export var name : String
@export var texture : Texture

@export var position : Vector2
@export var gun_tip_position : Vector2 

@export var bullet_res : Bullet

@export var fire_sound : AudioStream

var ammo : int
var total_ammo : int
@export var clip_size : int
@export var max_ammo : int

## Amount of bullets shot each time the gun fires
@export var bullet_count : int = 1

@export var reload_time : float

@export_range(-1.0,1.0) var bullet_spread : float = 0.0
