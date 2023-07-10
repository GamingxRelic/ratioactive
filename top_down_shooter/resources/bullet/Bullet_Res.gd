extends Resource
class_name Bullet

@export var bullet_type : String
var damage : float
@export var bullet_speed : float
@export var knockback_amount : float
@export var piercing : bool = false
@export var shader_mat : ShaderMaterial
@export var texture : Texture
@export var collision_polygon_verticies : PackedVector2Array
