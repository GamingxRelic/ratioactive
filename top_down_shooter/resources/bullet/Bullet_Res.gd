extends Resource
class_name Bullet

#@export var bullet_type : String #Unused
var damage : float
@export var bullet_speed : float
@export var knockback_amount : float
@export var piercing : bool = false
@export var shader_mat : ShaderMaterial
@export var texture : Texture
@export var collision_polygon_verticies : PackedVector2Array

@export var randomize_textures := false
@export var randomized_textures_array : Array[Texture]

## If the bullet should be spinning in circles as it moves
@export var sprite_rotating : bool = false
@export var sprite_rotate_speed : float = 0.0

@export var homing : bool = false
