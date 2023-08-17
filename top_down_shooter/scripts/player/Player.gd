extends CharacterBody2D

@export var movement_speed := 50.0
@export var accel := 8.0 
@export var decel := 10.0 

@onready var health_component : Node = $Health_Component
@onready var hurtbox_component = $Hurtbox_Component
var alive := true
@onready var gun = $Gun
@onready var sprite = $Sprite2D
@onready var reload_progress : TextureProgressBar = $ReloadProgress
@onready var reload_prog_timer : Timer = $ReloadProgTimer

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_player : AnimationPlayer = $AnimationPlayer

@onready var damage_sound : AudioStreamPlayer2D = $Audio/Damage_Sound
@onready var equip_weapon_sound : AudioStreamPlayer2D = $Audio/Equip_Weapon_Sound
@onready var heal_sound : AudioStreamPlayer2D = $Audio/Heal_Sound
@onready var fill_ammo_sound : AudioStreamPlayer2D = $Audio/Fill_Ammo_Sound

## Max distance for the gun circling the player
var gun_dist := 3.0

@onready var immunity_frames_timer : Timer = $Immunity_Frames_Timer as Timer

var damage_color_tween : Tween
var damage_color_tween_stop_time := 0.1

func _ready():
	anim_tree.active = true
	
	World.player = self
	World.player_pos = position
	World.player_hp = health_component.health
	World.player_max_hp = health_component.max_health
	World.player_points = 250
	World.player_hurtbox = hurtbox_component
	
	# Give mini pistol
	PlayerGun.weapons.append(preload("res://resources/weapon/mini_pistol.tres").duplicate())
	
	for i in PlayerGun.weapons:
		i.ammo = i.clip_size
		i.total_ammo = i.max_ammo
	
	
	# Set starting weapon as basic pistol
	PlayerGun.gun = PlayerGun.weapons[0]
	gun.set_gun_res(PlayerGun.gun)
	
	set_reload_prog_timer()
	
	gun.reload_signal.connect(gun_reload)
	PlayerGun.stop_reload.connect(stop_reload_prog)
	PlayerGun.gun_added.connect(_on_gun_added)
	PlayerGun.ammo_filled.connect(_on_ammo_filled)

func _process(_delta):
	if World.pickup_queue.size() != 0:
		World.pickup_queue[0].sprite.material = World.yellow_outline

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
		World.player_hp = health_component.health
			
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

func input():
#	if Input.is_action_just_pressed("throw_grenade"):
#		var grenade = preload("res://scenes/weapons/bullets/Grenade.tscn").instantiate()
#		grenade.global_position = global_position
#		grenade.aim_rotation_rad = get_angle_to(get_global_mouse_position())
#		World.current_level.entities.add_child(grenade)
		
#	if Input.is_action_just_pressed("space"):
#		World.emit_signal("next_wave")
		
#	if Input.is_action_just_pressed("mouse_5"):
#		World.UI.add_points(1000)
#		World.player_points += 1000
		
	if Input.is_action_pressed("left_click"):
		gun.fire()
	if Input.is_action_just_pressed("reload"):
		gun.reload()
		
	if Input.is_action_just_pressed("drop_weapon") and PlayerGun.weapons.size() > 1:
		drop_weapon()
		
	if Input.is_action_just_pressed("interact") and World.pickup_queue.size() > 0:
		pickup_weapon()
		
		# Weapon selections
	if Input.is_action_just_pressed("scroll_down"):
		previous_weapon()
	if Input.is_action_just_pressed("scroll_up"):
		next_weapon()

	if Input.is_action_just_pressed("1") and PlayerGun.weapons.size() >= 1 and PlayerGun.weapons[0] != null and PlayerGun.weapon_index != 0: # and !gun.is_reloading():
		select_weapon(0)
	if Input.is_action_just_pressed("2") and PlayerGun.weapons.size() >= 2 and PlayerGun.weapons[1] != null and PlayerGun.weapon_index != 1: # and !gun.is_reloading():
		select_weapon(1)
	if Input.is_action_just_pressed("3") and PlayerGun.weapons.size() >= 3 and PlayerGun.weapons[2] != null and PlayerGun.weapon_index != 2: # and !gun.is_reloading():
		select_weapon(2)
	if Input.is_action_just_pressed("4") and PlayerGun.weapons.size() >= 4 and PlayerGun.weapons[3] != null and PlayerGun.weapon_index != 3: # and !gun.is_reloading():
		select_weapon(3)
	
func _on_gun_added() -> void:
	select_weapon(PlayerGun.weapons.size()-1)
	
func drop_weapon() -> void:
	stop_reload_prog()
	
	# Spawn dropped gun
	var dropped_gun = preload("res://scenes/entities/drops/Dropped_Weapon.tscn").instantiate()
	dropped_gun.weapon_res = PlayerGun.gun
	dropped_gun.global_position = global_position
	World.current_level.entities.add_child(dropped_gun)
	
	# Remove gun from player inventory
	PlayerGun.weapons.pop_at(PlayerGun.weapon_index)
	
	if PlayerGun.weapons.size() == 1:
		select_weapon(0)
	else:
		previous_weapon()
	return
	
	
	# It has an error when trying to drop the last weapon in player inventory. Plz fix <3 xoxo love you me. Good luck dawg you got this :)
	
func pickup_weapon() -> void:
	World.pickup_queue[0].pickup()
	
func select_weapon(selection : int):
	if PlayerGun.weapons[selection] != null:
		PlayerGun.gun = PlayerGun.weapons[selection]
		PlayerGun.weapon_index = selection
		gun.set_gun_res(PlayerGun.gun)
		stop_reload_prog()
		gun.reloading = false
		gun.reload_timer.stop()
		gun.fire_cooldown.start()
		set_reload_prog_timer()
		equip_weapon_sound.play()

func next_weapon() -> void:
	if PlayerGun.weapon_index == PlayerGun.weapons.size()-1 and PlayerGun.weapons.size() > 1:
		select_weapon(0)
	elif PlayerGun.weapon_index+1 <= PlayerGun.weapons.size()-1 and PlayerGun.weapons[PlayerGun.weapon_index+1] != null:
		select_weapon(PlayerGun.weapon_index+1)
	return
	
func previous_weapon():
	if PlayerGun.weapon_index-1 < 0 and PlayerGun.weapons.size() != 1:
		for i in PlayerGun.weapons.size():
			var selection = PlayerGun.weapons.size()-1-i
			if PlayerGun.weapons[selection] != null:
				select_weapon(selection)
				return
	elif PlayerGun.weapons[PlayerGun.weapon_index-1] != null and PlayerGun.weapons.size() != 1:
		select_weapon(PlayerGun.weapon_index-1)
		return
	return

# I guess I set things up in a way that doesn't even require this method. Nice, good job me :)
#func save_weapon_info():
#	PlayerGun.weapons[PlayerGun.weapon_index].ammo = PlayerGun.gun.ammo
#	PlayerGun.weapons[PlayerGun.weapon_index].total_ammo = PlayerGun.gun.total_ammo
#	return

func set_reload_prog_timer():
	reload_progress.max_value = PlayerGun.gun.reload_time
	reload_progress.step = PlayerGun.gun.reload_time/10
	reload_prog_timer.wait_time = float(PlayerGun.gun.reload_time)/10
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
		if !health_component.immune:
			damage_sound.play()
			health_component.take_damage(dmg_amnt)
			velocity += knockback_amnt
			health_component.immune = true
			immunity_frames_timer.start()
			damage_color_tween = get_tree().create_tween()
			sprite.modulate = Color(1,0,0,1)
			damage_color_tween.parallel().tween_property(sprite, "modulate",Color(1,1,1,1), damage_color_tween_stop_time)
	return

func _on_immunity_frames_timer_timeout() -> void:
	health_component.immune = false

func heal() -> void:
	health_component.health = health_component.max_health
	World.player_hp = World.player_max_hp
	heal_sound.play()

func _on_health_component_death():
	alive = false
	anim_tree.active = false
	World.player_hp = 0.0
	anim_player.play("death")

func _on_ammo_filled() -> void:
	fill_ammo_sound.play()
	return

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		#World.kill_all_enemies.emit()
		World.player_death.emit()
		process_mode = Node.PROCESS_MODE_DISABLED
