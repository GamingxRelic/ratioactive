extends CharacterBody2D

var bullet_res : Bullet 
@onready var sprite : Sprite2D = $Sprite2D
var aim_rotation_rad : float

func _ready():
	bullet_res = PlayerGun.gun.bullet_res
	
	if bullet_res.shader_mat != null:
		material = bullet_res.shader_mat
	if bullet_res.randomize_textures:
		var rand_index := randi_range(0,bullet_res.randomized_textures_array.size()-1)
		sprite.texture = bullet_res.randomized_textures_array[rand_index] if bullet_res.randomized_textures_array[rand_index] != null else bullet_res.texture
	elif bullet_res.texture != null:
		sprite.texture = bullet_res.texture
	
	rotate(aim_rotation_rad)
	
func _physics_process(_delta):
	velocity = transform.x * bullet_res.bullet_speed
	
	if bullet_res.sprite_rotating:
		spin(bullet_res.sprite_rotate_speed)
	
	if bullet_res.homing:
		look_at(get_global_mouse_position())

	move_and_slide()

func spin(rotate_speed : float):
	sprite.rotation_degrees += rotate_speed

func _on_despawn_timer_timeout():
	self.queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player_can_damage"):
		body.hurtbox_component.damage(PlayerGun.gun.damage, velocity * bullet_res.knockback_amount)
		if !bullet_res.piercing:
			self.queue_free()
	elif (!body.is_in_group("bullet_passable") and !body.is_in_group("player")) or body.is_in_group("bullet_impassable"):
		self.queue_free()
