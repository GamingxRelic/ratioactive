extends CharacterBody2D

@export var movement_speed := 50.0
@export var accel := 8.0 
@export var decel := 10.0 

@export var health_comp : Node
var alive := true
@onready var gun = $Gun
@onready var sprite = $Sprite2D
@onready var reload_progress : TextureProgressBar = $ReloadProgress
@onready var reload_prog_timer : Timer = $ReloadProgTimer

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_player : AnimationPlayer = $AnimationPlayer

## Max distance for the gun circling the player
var gun_dist := 3.0

@onready var yellow_outline = preload("res://assets/shaders/yellow_outline.tres")

@onready var immunity_frames_timer : Timer = $Immunity_Frames_Timer as Timer

var damage_color_tween : Tween
var damage_color_tween_stop_time := 0.1

func _ready():
	anim_tree.active = true
	
	World.player = self
	World.player_pos = position
	World.player_hp = health_comp.health
	World.player_points = 0
	World.player_hurtbox = $Hurtbox_Component
	
	# Give mini pistol
	World.player_weapons.append(preload("res://resources/weapon/mini_pistol.tres").duplicate())
	
	# Give test guns
	#World.player_weapons.append(preload("res://resources/weapon/ak-47.tres").duplicate())
	#World.player_weapons.append(preload("res://resources/weapon/sawed_off.tres").duplicate())
	#World.player_weapons.append(preload("res://resources/weapon/ruahil.tres").duplicate())
	
	for i in World.player_weapons:
		i.ammo = i.clip_size
		i.total_ammo = i.max_ammo
	
	
	# Set starting weapon as basic pistol
	World.player_gun = World.player_weapons[0]
	gun.set_gun_res(World.player_gun)
	
	set_reload_prog_timer()
	
	gun.reload_signal.connect(gun_reload)
	

func _process(_delta):
	if World.pickup_queue.size() != 0:
		World.pickup_queue[0].sprite.material = yellow_outline

func _physics_process(delta):
	if alive:
		movement(delta)
		input()
		animation()
		
		#velocity += knockback
	#	if knockback != Vector2.ZERO:
	#		velocity.x += lerp(knockback.x, 0.0, 0.9)
	#		velocity.y += lerp(knockback.y, 0.0, 0.9)
		
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

# Last working on making it so that if the player is 
# idle but shooting, the idle animation shouldnt play. it should just be the 
# first frame of the idle animation. maybe, see how it looks.

func input():
	if Input.is_action_just_pressed("mouse_5"):
		var new_enemy = preload("res://scenes/entities/enemies/Enemy.tscn").instantiate()
		new_enemy.global_position = get_global_mouse_position()
		get_node("/root/World").add_child(new_enemy)
	if Input.is_action_just_pressed("space"):
		#World.spawn_enemies.emit()
		World.emit_signal("next_wave")
		
		
	if Input.is_action_pressed("left_click"):
		gun.fire()
	if Input.is_action_just_pressed("reload"):
		gun.reload()
		
	if Input.is_action_just_pressed("drop_weapon") and World.player_weapons.size() > 1:
		drop_weapon()
		
	if Input.is_action_just_pressed("interact") and World.pickup_queue.size() > 0:
		pickup_weapon()
		
		# Weapon selections
	if Input.is_action_just_pressed("scroll_down"):
		previous_weapon()
	if Input.is_action_just_pressed("scroll_up"):
		next_weapon()

	if Input.is_action_just_pressed("1") and World.player_weapons.size() >= 1 and World.player_weapons[0] != null and World.player_weapon_index != 0: # and !gun.is_reloading():
		select_weapon(0)
	if Input.is_action_just_pressed("2") and World.player_weapons.size() >= 2 and World.player_weapons[1] != null and World.player_weapon_index != 1: # and !gun.is_reloading():
		select_weapon(1)
	if Input.is_action_just_pressed("3") and World.player_weapons.size() >= 3 and World.player_weapons[2] != null and World.player_weapon_index != 2: # and !gun.is_reloading():
		select_weapon(2)
	if Input.is_action_just_pressed("4") and World.player_weapons.size() >= 4 and World.player_weapons[3] != null and World.player_weapon_index != 3: # and !gun.is_reloading():
		select_weapon(3)
	
	
func drop_weapon() -> void:
	stop_reload_prog()
	
	# Spawn dropped gun
	var dropped_gun = preload("res://scenes/entities/drops/Dropped_Weapon.tscn").instantiate()
	dropped_gun.weapon_res = World.player_gun
	dropped_gun.global_position = global_position
	get_node("/root/World").add_child(dropped_gun)
	
	# Remove gun from player inventory
	World.player_weapons.pop_at(World.player_weapon_index)
	
	if World.player_weapons.size() == 1:
		select_weapon(0)
	else:
		previous_weapon()
	return
	
	
	# It has an error when trying to drop the last weapon in player inventory. Plz fix <3 xoxo love you me. Good luck dawg you got this :)
	
func pickup_weapon() -> void:
	World.pickup_queue[0].pickup()
	
func select_weapon(selection : int):
	if World.player_weapons[selection] != null:
		World.player_gun = World.player_weapons[selection]
		World.player_weapon_index = selection
		gun.set_gun_res(World.player_gun)
		stop_reload_prog()
		gun.reloading = false
		gun.reload_timer.stop()
		gun.fire_cooldown.start()
		set_reload_prog_timer()

func next_weapon() -> void:
	if World.player_weapon_index == World.player_weapons.size()-1 and World.player_weapons.size() > 1:
		select_weapon(0)
	elif World.player_weapon_index+1 <= World.player_weapons.size()-1 and World.player_weapons[World.player_weapon_index+1] != null:
		select_weapon(World.player_weapon_index+1)
	return
	
func previous_weapon():
	if World.player_weapon_index-1 < 0 and World.player_weapons.size() != 1:
		for i in World.player_weapons.size():
			print(i)
			var selection = World.player_weapons.size()-1-i
			if World.player_weapons[selection] != null:
				select_weapon(selection)
				return
	elif World.player_weapons[World.player_weapon_index-1] != null and World.player_weapons.size() != 1:
		select_weapon(World.player_weapon_index-1)
		return
	return

# I guess I set things up in a way that doesn't even require this method. Nice, good job me :)
#func save_weapon_info():
#	World.player_weapons[World.player_weapon_index].ammo = World.player_gun.ammo
#	World.player_weapons[World.player_weapon_index].total_ammo = World.player_gun.total_ammo
#	return

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
		reload_prog_timer.stop()
	return

func _on_view_price_body_entered(body):
	if body.is_in_group("buyable") and body.is_in_group("can_change_label_visibility"):
		body.find_child("Text_Label_Component").show()
		body.sprite.material = preload("res://assets/shaders/outline.tres")
		

func _on_view_price_body_exited(body):
	if body.is_in_group("buyable") and body.is_in_group("can_change_label_visibility"):
		body.find_child("Text_Label_Component").hide()
		body.sprite.material = null

func _on_view_price_area_entered(area):
	if area.is_in_group("interactable"):
		area.find_child("Text_Label_Component").show()
		area.sprite.material = preload("res://assets/shaders/outline.tres")

func _on_view_price_area_exited(area):
	if area.is_in_group("interactable"):
		area.find_child("Text_Label_Component").hide()
		area.sprite.material = null


# For detecting if spawners should be considered active or not
func _on_enemy_spawner_range_area_entered(area):
	if area.is_in_group("spawner"):
		area.active = true
		area.attempt_enemy_spawn()

func _on_enemy_spawner_range_area_exited(area):
	if area.is_in_group("spawner"):
		area.active = false

func _on_hurtbox_component_took_damage(dmg_amnt : float, knockback_amnt : Vector2) -> void:	
	if alive:
		if !health_comp.immune:
			print("ow")
			health_comp.take_damage(dmg_amnt)
			velocity += knockback_amnt
			health_comp.immune = true
			immunity_frames_timer.start()
			damage_color_tween = get_tree().create_tween()
			sprite.modulate = Color(1,0,0,1)
			damage_color_tween.parallel().tween_property(sprite, "modulate",Color(1,1,1,1), damage_color_tween_stop_time)
	return

func _on_immunity_frames_timer_timeout() -> void:
	health_comp.immune = false


func _on_health_component_death():
	alive = false
	anim_tree.active = false
	World.player_hp = 0.0
	anim_player.play("death")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		World.kill_all_enemies.emit()
		process_mode = Node.PROCESS_MODE_DISABLED
