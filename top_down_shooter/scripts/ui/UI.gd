extends Control

@onready var ammo_label : Label = $CanvasLayer/AmmoLabel
@onready var healh_prog_bar : TextureProgressBar = $CanvasLayer/HealthProgressBar

func _process(_delta):
	set_ammo_text(World.player_ammo, World.player_max_ammo)
	set_health_value(World.player_hp)


func set_ammo_text(ammo_min : int, ammo_max : int):
	ammo_label.text = str(ammo_min) + " / " + str(ammo_max)
	
func set_health_value(health : float):
	healh_prog_bar.value = health
	
