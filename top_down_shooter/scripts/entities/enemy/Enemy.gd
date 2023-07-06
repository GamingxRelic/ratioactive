extends CharacterBody2D

@export var speed := 20
@onready var target_pos : Vector2 = World.player_pos
@export var navigation_agent : NavigationAgent2D
@onready var sprite : Sprite2D = $Sprite2D as Sprite2D
@onready var health_component = $Health_Component
@onready var hurtbox_component = $Hurtbox_Component
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var health_bar : TextureProgressBar = $Health_Bar
var knockback := Vector2(0,0)
var knockback_tween : Tween
var knockback_tween_stop_time := 1.0
var damage_color_tween : Tween
var damage_color_tween_stop_time := 0.1
var alive := true
	

func _ready():
#	set_movement_target(target_pos)
	set_movement_target(World.player_pos)
	pass

func _physics_process(_delta):
#	target_pos = World.player_pos
#	set_movement_target(target_pos)

	
#	if navigation_agent.is_navigation_finished():
#		if knockback != Vector2.ZERO:
#			velocity+=knockback
#			move_and_slide()
#		return

#	var angle_to_player := rad_to_deg(get_angle_to(target_pos))
#	flip_sprite(angle_to_player)

#	var dir = to_local(navigation_agent.get_next_path_position()).normalized()
#	velocity = dir*speed + knockback

	if alive:
		health_bar.value = health_component.health
		
		var current_agent_position : Vector2 = global_position
		var next_path_position : Vector2 = navigation_agent.get_next_path_position()
	#
		var new_velocity : Vector2 = next_path_position - current_agent_position
		new_velocity = new_velocity.normalized()
		new_velocity *= speed

		velocity = new_velocity + knockback

		move_and_slide()

func set_movement_target(movement_target : Vector2):
	navigation_agent.target_position = movement_target

func flip_sprite(angle):
	if angle < -90 or angle > 90:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1


func _on_health_component_death():
	alive = false
	hurtbox_component.set_process(false)
	health_bar.visible = false
	anim.play("death")

func _on_hurtbox_component_took_damage(dmg_amnt : float, knockback_amnt : Vector2):
	#print("took ", dmg_amnt, " dmg and ", knockback_amnt, " knockback") #Debug
	#anim_tree.set("parameters/Sound_Player/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if alive:
		audio.play()
		knockback = knockback_amnt
		if(knockback_tween):
			knockback_tween.kill()
			
		knockback_tween = get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback", Vector2(0,0), knockback_tween_stop_time)
		damage_color_tween = get_tree().create_tween()
		sprite.modulate = Color(1,0,0,1)
		damage_color_tween.parallel().tween_property(sprite, "modulate",Color(1,1,1,1), damage_color_tween_stop_time)
		health_component.take_damage(dmg_amnt)

func _on_navigation_timer_timeout():
#	print("nav = ", World.player_pos) #Debug
	set_movement_target(World.player_pos)


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"death":
			queue_free()
			#print("hi") #It will still run this after deleting. This is super useful.
