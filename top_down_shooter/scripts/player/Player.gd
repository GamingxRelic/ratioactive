extends CharacterBody2D

@export var movement_speed := 50.0
@export var accel := 8.0 
@export var decel := 10.0 

@export var health_comp : Node
@onready var gun = $Gun
@onready var sprite = $Sprite2D
@onready var reload_progress : TextureProgressBar = $ReloadProgress
@onready var reload_prog_timer : Timer = $ReloadProgTimer

@onready var anim_tree : AnimationTree = $AnimationTree

## Max distance for the gun circling the player
var gun_dist := 3.0

func _ready():
	anim_tree.active = true
	
	World.player = self
	World.player_pos = position
	World.player_hp = health_comp.health
	World.player_points = 1000
	
	# Give mini pistol
	World.player_weapons.append(preload("res://resources/weapon/mini_pistol.tres").duplicate())
	
	# Give test guns
	World.player_weapons.append(preload("res://resources/weapon/ak-47.tres").duplicate())
	World.player_weapons.append(preload("res://resources/weapon/sawed_off.tres").duplicate())
	
	for i in World.player_weapons:
		i.ammo = i.clip_size
		i.total_ammo = i.max_ammo
	
	
	# Set starting weapon as basic pistol
	World.player_gun = World.player_weapons[0]
	gun.set_gun_res(World.player_gun)
	
	set_reload_prog_timer()
	
	gun.reload_signal.connect(gun_reload)
	

func _physics_process(delta):
	movement(delta)
	input()
	animation()
	
	World.player_pos = position
	World.player_hp = health_comp.health
		
	if reload_progress.value > reload_progress.max_value:
		reload_progress.value = 0
	
	gun_circle_player()
	
	move_and_slide()
	
	
func movement(delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity.x = lerp(velocity.x, input_direction.x*movement_speed, accel*delta) if input_direction.x != 0 else lerp(velocity.x, 0.0, decel*delta)
	velocity.y = lerp(velocity.y, input_direction.y*movement_speed, accel*delta) if input_direction.y != 0 else lerp(velocity.y, 0.0, decel*delta)

## Make the gun circle the player instead of directly being on them.
func gun_circle_player():
	var mouse_pos = get_local_mouse_position()
	var dir = Vector2.ZERO.direction_to(mouse_pos)
	gun.position = lerp(gun.position, dir * gun_dist, 0.2)
	return


func animation(): 
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Set idle or running
	if input_direction == Vector2.ZERO:
		anim_tree.set("parameters/MoveOrIdle/transition_request", "idle")
	else:
		anim_tree.set("parameters/MoveOrIdle/transition_request", "run")

	# Choose which animation it should be (L,R,U,D)
	if input_direction.x < 0 and input_direction.y == 0: 
		anim_tree.set("parameters/run_anim/transition_request", "run_left")
		anim_tree.set("parameters/idle_anim/transition_request", "idle_left")
	elif input_direction.x > 0 and input_direction.y == 0: 
		anim_tree.set("parameters/run_anim/transition_request", "run_right")
		anim_tree.set("parameters/idle_anim/transition_request", "idle_right")
# This part acts kinda weird when you start by walking down or up and then moving side to side. 
#	elif input_direction.y > 0 and input_direction.x == 0: 
#		anim_tree.set("parameters/run_anim/transition_request", "run_down")
#		anim_tree.set("parameters/idle_anim/transition_request", "idle_down")
#	elif input_direction.y < 0 and input_direction.x == 0: 
#		anim_tree.set("parameters/run_anim/transition_request", "run_up")
#		anim_tree.set("parameters/idle_anim/transition_request", "idle_up")

func input():
	if Input.is_action_just_pressed("mouse_5"):
		var new_enemy = preload("res://scenes/entities/enemies/Enemy.tscn").instantiate()
		#new_enemy.translate(get_global_mouse_position())
		new_enemy.global_position = get_global_mouse_position()
		get_node("/root/World").add_child(new_enemy)
	if Input.is_action_just_pressed("space"):
		print("pg - ", World.player_gun.ammo)
		print("0 - ", World.player_weapons[0].ammo)
		print(World.player_weapons[0].name)
		
		
	if Input.is_action_pressed("left_click"):
		gun.fire()
	if Input.is_action_just_pressed("reload"):
		gun.reload()
		
		# Weapon selections
	if Input.is_action_just_pressed("scroll_down"):
		next_weapon()
	if Input.is_action_just_pressed("scroll_up"):
		previous_weapon()

	if Input.is_action_just_pressed("1") and World.player_weapons[0] != null and World.player_weapon_index != 0 :# and !gun.is_reloading():
		select_weapon(0)
	if Input.is_action_just_pressed("2") and World.player_weapons[1] != null and World.player_weapon_index != 1:# and !gun.is_reloading():
		select_weapon(1)
	if Input.is_action_just_pressed("3") and World.player_weapons[2] != null and World.player_weapon_index != 2:# and !gun.is_reloading():
		select_weapon(2)
	
	
func select_weapon(selection : int):
	if World.player_weapons[selection] != null:
		save_weapon_info()
		World.player_gun = World.player_weapons[selection]
		World.player_weapon_index = selection
		gun.set_gun_res(World.player_gun)
		stop_reload_prog()
		gun.reloading = false
		gun.reload_timer.stop()
		gun.fire_cooldown.start()
		set_reload_prog_timer()

func next_weapon():
	if World.player_weapon_index == World.player_weapons.size()-1:
		select_weapon(0)
	elif World.player_weapon_index+1 < World.player_weapons.size() and World.player_weapons[World.player_weapon_index+1] != null:
		select_weapon(World.player_weapon_index+1)
	return
	
func previous_weapon():
	if World.player_weapon_index-1 < 0:
		for i in World.player_weapons.size():
			var selection = World.player_weapons.size()-1-i
			if World.player_weapons[selection] != null:
				select_weapon(selection)
				return
	elif World.player_weapons[World.player_weapon_index-1] != null:
		select_weapon(World.player_weapon_index-1)
	return

func save_weapon_info():
	World.player_weapons[World.player_weapon_index].ammo = World.player_gun.ammo
	World.player_weapons[World.player_weapon_index].total_ammo = World.player_gun.total_ammo
	return

func set_reload_prog_timer():
	reload_progress.max_value = World.player_gun.reload_time
	reload_progress.step = World.player_gun.reload_time/10
	reload_prog_timer.wait_time = float(World.player_gun.reload_time)/10
	return

func stop_reload_prog():
	reload_prog_timer.stop()
	reload_progress.value = 0
	return

# Will be called when the gun is reloading. 
# Starts the reload progress timer
func gun_reload():	
	reload_progress.value = float(reload_progress.max_value)/10
	reload_prog_timer.start()
	return

func _on_reload_prog_timer_timeout():
	reload_progress.value += float(reload_progress.max_value)/10
	if reload_progress.value > reload_progress.max_value:
#		reload_progress.value = 0
		reload_prog_timer.stop()
#	else:
#		reload_progress.value += float(reload_progress.max_value)/10
	return

func _on_view_price_body_entered(body):
	if body.is_in_group("buyable") and body.is_in_group("can_change_label_visibility"):
		print(body)
		body.find_child("Text_Label_Component").show()

func _on_view_price_body_exited(body):
	if body.is_in_group("buyable") and body.is_in_group("can_change_label_visibility"):
		body.find_child("Text_Label_Component").hide()
