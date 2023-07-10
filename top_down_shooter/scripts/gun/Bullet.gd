extends CharacterBody2D
@onready var bullet_res : Bullet
@onready var sprite : Sprite2D = $Sprite2D
var aim_rotation_rad : float

func _ready():
	if bullet_res.shader_mat != null:
		material = bullet_res.shader_mat
	if bullet_res.texture != null:
		sprite.texture = bullet_res.texture
	
	#rotate(get_angle_to(get_global_mouse_position()))
	rotate(aim_rotation_rad)
	
func _physics_process(_delta):
	velocity = transform.x * bullet_res.bullet_speed
	move_and_slide()

func _on_despawn_timer_timeout():
	self.queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player_can_damage"):
		body.hurtbox_component.damage(bullet_res.damage, velocity * bullet_res.knockback_amount)
		World.UI.add_points(10)
		World.player_points+=10
		if !bullet_res.piercing:
			self.queue_free()
	elif !body.is_in_group("player"):
		self.queue_free()
