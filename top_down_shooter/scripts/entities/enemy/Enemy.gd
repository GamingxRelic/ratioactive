extends CharacterBody2D

@export var speed := 20
@export var damage := 50
@export var knockback_amount := 3

@onready var attempt_player_damage_timer : Timer = $Attempt_Player_Damage_Timer as Timer


@onready var target_pos : Vector2 = World.player_pos
@export var navigation_agent : NavigationAgent2D

@onready var sprite : Sprite2D = $Sprite2D as Sprite2D
@onready var health_component = $Health_Component
@onready var hurtbox_component = $Hurtbox_Component

@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var health_bar : TextureProgressBar = $Health_Bar
@onready var immunity_frames_timer : Timer = $Immunity_Frames_Timer as Timer
var knockback := Vector2(0,0)
var knockback_tween : Tween
var knockback_tween_stop_time := 1.0
var damage_color_tween : Tween
var damage_color_tween_stop_time := 0.05
var alive := true
@export var active := true

func _ready():
	World.enemy_count += 1
	World.total_wave_enemies_spawned += 1
	look_at(World.player_pos)
	flip_sprite(rotation_degrees)
	anim.play("spawn")
	set_movement_target(World.player_pos)
	World.connect("kill_all_enemies", _on_kill_all_enemies)
	pass

func _physics_process(_delta):
	if alive and active:
		health_bar.value = health_component.health
		
		var current_agent_position : Vector2 = global_position
		var next_path_position : Vector2 = navigation_agent.get_next_path_position()
	#
		var new_velocity : Vector2 = next_path_position - current_agent_position
		new_velocity = new_velocity.normalized()
		new_velocity *= speed

		velocity = new_velocity + knockback
		
		look_at(World.player_pos)
		flip_sprite(rotation_degrees)

		move_and_slide()

func set_movement_target(movement_target : Vector2):
	navigation_agent.target_position = movement_target

func flip_sprite(angle):
	if angle < -90 or angle > 90:
		sprite.scale.y = -1
	else:
		sprite.scale.y = 1

func _on_health_component_death():
	alive = false
	World.UI.add_points(20)
	World.player_points+=30
	health_bar.visible = false
	hurtbox_component.set_process(false)
	anim.play("death")

func _on_hurtbox_component_took_damage(dmg_amnt : float, knockback_amnt : Vector2):
	if alive:
		World.UI.add_points(10)
		World.player_points+=10
		audio.play()
		knockback = knockback_amnt
		if(knockback_tween):
			knockback_tween.kill()
			
		knockback_tween = get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback", Vector2(0,0), knockback_tween_stop_time)
		damage_color_tween = get_tree().create_tween()
		sprite.modulate = Color(1,0,0,1)
		damage_color_tween.parallel().tween_property(sprite, "modulate",Color(1,1,1,1), damage_color_tween_stop_time)
		if !health_component.immune:
			health_component.take_damage(dmg_amnt)
			health_component.immune = true
			immunity_frames_timer.start()

func _on_navigation_timer_timeout():
	set_movement_target(World.player_pos)


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"death":
			World.enemy_count -= 1
			World.remaining_wave_enemy_count -= 1
			queue_free()


func _on_immunity_frames_timer_timeout():
	health_component.immune = false


func _on_attackbox_component_area_entered(area):
	if area.is_in_group("player_hurtbox"):
		area.damage(damage, velocity*knockback_amount)
		attempt_player_damage_timer.start()

func _on_attackbox_component_area_exited(area):
	if area.is_in_group("player_hurtbox"):
		attempt_player_damage_timer.stop()

func _on_attempt_player_damage_timer_timeout():
	World.player_hurtbox.damage(damage, velocity*knockback_amount)

func _on_kill_all_enemies() -> void:
	queue_free()


