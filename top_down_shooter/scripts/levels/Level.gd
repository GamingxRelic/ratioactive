extends Node2D

class_name Level

@onready var anim_player : AnimationPlayer = $AnimationPlayer as AnimationPlayer
@onready var wave_timer : Timer = $Wave_Intermission_Timer as Timer
@onready var countdown_timer : Timer = $Wave_Countdown_Timer as Timer

var wave := 0
var timer_countdown_value := 0
@export var max_enemy_count := 24

@export var wave_enemy_amount := 0.15*(wave*wave)+0.3*(wave)+8

@onready var entities = $Entities

# Audio
@onready var kaching_sound : AudioStreamPlayer2D = $Audio/Kaching_Sound

func _ready() -> void:
	World.current_level = self
	World.game_running = true
	
	World.max_enemy_count = max_enemy_count
	anim_player.play("reveal_map")
	World.connect("next_wave", _on_next_wave)
	
	World.remaining_wave_enemy_count_changed.connect(_on_remaining_wave_enemy_count_changed)
	
	World.kaching_sound.connect(_on_kaching_sound)

func _on_next_wave() -> void:
	if wave == 0:
		wave_timer.wait_time = 3
	else:
		wave_timer.wait_time = 1
	timer_countdown_value = int(wave_timer.wait_time)
	World.UI.set_wave_label("New Wave In " + str(timer_countdown_value))
	World.UI.play_animation("show_wave_label")
	timer_countdown_value -= 1
	
	countdown_timer.start()
	wave_timer.start()

## Start new wave
func _on_wave_intermission_timer_timeout():
	countdown_timer.stop()
	# I gotta set up the $Attempt_Enemy_Spawns
	World.cantuna_cycle_weapon.emit()
	
	wave += 1
	World.wave = wave
	World.UI.change_wave_label(wave)
	
	wave_enemy_amount = clamp(floor(0.15*(wave*wave)+0.3*(wave)+8), 1, 285)
	World.max_wave_enemy_count = int(wave_enemy_amount)
	World.remaining_wave_enemy_count = World.max_wave_enemy_count
	World.total_wave_enemies_spawned = 0
	
	World.emit_signal("spawn_enemies")

func _on_wave_countdown_timer_timeout() -> void:
	World.UI.set_wave_label("New Wave In " + str(timer_countdown_value))
	timer_countdown_value -= 1
	if timer_countdown_value == 0:
		World.UI.play_animation("hide_wave_label")

## Handle wave change when remaining enemies is zero
func _on_remaining_wave_enemy_count_changed() -> void:
	if World.remaining_wave_enemy_count == 0:
		World.next_wave.emit()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "reveal_map":
		#pass
		World.next_wave.emit()

func _on_attempt_enemy_spawns_timeout():
	if wave_timer.is_stopped():
		World.spawn_enemies.emit()

func _on_kaching_sound() -> void:
	kaching_sound.play()
