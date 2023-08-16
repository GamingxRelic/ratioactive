extends Control

@onready var canvas_layer : CanvasLayer = $CanvasLayer

@onready var ammo_label : Label = $CanvasLayer/AmmoLabel
@onready var weapon_name_label : Label = $CanvasLayer/WeaponNameLabel
@onready var health_prog_bar : TextureProgressBar = $CanvasLayer/HealthProgressBar
@onready var points_label : Label = $CanvasLayer/PointsLabel
@onready var wave_label : Label = $CanvasLayer/WaveLabel

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var tween : Tween

func _ready() -> void:
	World.UI = self
	update_points()
	

func _process(_delta) -> void:
	if World.game_running:
		set_ammo_text(PlayerGun.gun.ammo, PlayerGun.gun.total_ammo)
		set_health_value(World.player_hp)
		set_weapon_name_label(PlayerGun.gun.name)

func set_ammo_text(ammo_min : int, ammo_max : int) -> void:
	ammo_label.text = str(ammo_min) + " / " + str(ammo_max)
	return

func set_weapon_name_label(weap_name : String) -> void:
	weapon_name_label.text = weap_name

func set_health_value(health : float) -> void:
	health_prog_bar.value = health
	return
	
func set_points_text(points : int) -> void:
	points_label.text = "$" + str(points)
	return
	
func add_points(points: int) -> void:
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_method(set_points_text,World.player_points, World.player_points+points, 0.1)
	return
	
func subtract_points(points: int) -> void:
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_method(set_points_text,World.player_points, World.player_points-points, 0.3)
	return
	
func update_points() -> void:
	if tween != null and tween.is_running():
		tween.stop()
	set_points_text(World.player_points)
	return
	
func play_animation(anim_name : String) -> void:
	match anim_name:
		"show_wave_label":
			anim_player.play("show_wave_label")
			return
		"hide_wave_label":
			anim_player.play("hide_wave_label")
			return
		"change_wave_label":
			anim_player.play("change_wave_label")
			return

## For changing the wave number
func change_wave_label(wave : int) -> void:
	anim_player.play("change_wave_label")
	wave_label.text = "Wave " + str(wave)
	
	
## For setting the wave label text
func set_wave_label(value : String) -> void:
	wave_label.text = value


