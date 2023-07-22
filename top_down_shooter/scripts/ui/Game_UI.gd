extends Control

@onready var ammo_label : Label = $CanvasLayer/AmmoLabel
@onready var health_prog_bar : TextureProgressBar = $CanvasLayer/HealthProgressBar
@onready var points_label : Label = $CanvasLayer/PointsLabel

func _ready():
	World.UI = self
	update_points()

func _process(_delta):
	set_ammo_text(World.player_gun.ammo, World.player_gun.total_ammo)
	set_health_value(World.player_hp)

func set_ammo_text(ammo_min : int, ammo_max : int):
	ammo_label.text = str(ammo_min) + " / " + str(ammo_max)
	return
	
func set_health_value(health : float):
	health_prog_bar.value = health
	return
	
func set_points_text(points : int):
	points_label.text = "$" + str(points)
	return
	
func add_points(points: int):
	var tween = create_tween()
	tween.tween_method(set_points_text,World.player_points, World.player_points+points, 0.1)
	return
	
func subtract_points(points: int):
	var tween = create_tween()
	tween.tween_method(set_points_text,World.player_points, World.player_points-points, 0.3)
	return
	
func update_points():
	set_points_text(World.player_points)
	return
