extends CharacterBody2D

@export var movement_speed := 70.0
@export var accel := 8.0 
@export var decel := 10.0 

@export var health_comp : Node
@onready var gun = $Gun
@onready var sprite = $Sprite2D

func _ready():
	World.player = self
	World.player_pos = position
	World.player_hp = health_comp.health
	
	World.player_weapons.append(preload("res://resources/weapon/mini_pistol.tres").duplicate())
	World.player_weapons.append(preload("res://resources/weapon/ak-47.tres").duplicate())
	
	gun.set_gun_res(World.player_weapons[0])

func _physics_process(delta):
	movement(delta)
	flip_scale()
	input()
	
	World.player_pos = position
	World.player_hp = health_comp.health
	
	World.player_ammo = World.player_gun.ammo
	World.player_max_ammo = World.player_gun.total_ammo
		
	move_and_slide()
	
	
func movement(delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity.x = lerp(velocity.x, input_direction.x*movement_speed, accel*delta) if input_direction.x != 0 else lerp(velocity.x, 0.0, decel*delta)
	velocity.y = lerp(velocity.y, input_direction.y*movement_speed, accel*delta) if input_direction.y != 0 else lerp(velocity.y, 0.0, decel*delta)

func flip_scale():
	if gun.scale.y == -1:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1

func input():
	if Input.is_action_pressed("left_click"):
		gun.fire()
	if Input.is_action_just_pressed("reload"):
		gun.reload()
	if Input.is_action_just_pressed("1") and !gun.is_reloading():
		World.player_gun = World.player_weapons[0]
		gun.set_gun_res(World.player_weapons[0])
	if Input.is_action_just_pressed("2") and World.player_weapons[1] != null and !gun.is_reloading():
		World.player_gun = World.player_weapons[1]
		gun.set_gun_res(World.player_weapons[1])
