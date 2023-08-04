extends Resource
class_name Weapon

@export var rate_of_fire : float
@export var damage : float
@export var name : String
@export var texture : Texture

@export var position : Vector2
@export var gun_tip_position : Vector2 

@export var bullet : PackedScene
@export var bullet_res : Bullet

## Current ammo in the clip
@export var ammo : int
## Current ammo in reserves
@export var total_ammo : int

@export var clip_size : int
@export var max_ammo : int

@export var reload_time : float

## Price at the Cantuna Shop
@export var cantuna_price : int = 0

@export_range(-1.0,1.0) var bullet_spread : float = 0.0

## Amount of bullets shot each time the gun fires
@export var bullet_count : int = 1
## Will shoot a random bullet count in range of the randomized_bullet_count_min and randomized_bullet_count_max
@export var randomize_bullet_count : bool = false
@export var randomized_bullet_count_min : int = 1
@export var randomized_bullet_count_max : int = 1

@export var fire_sound : AudioStream

## How large the point light at the gun tip should be. Controls muzzle flash. 
@export var fire_flash_scale : float = 0.05
@export var fire_flash_color : Color = Color("e6d066")
@export var fire_flash_energy : float = 1.0
