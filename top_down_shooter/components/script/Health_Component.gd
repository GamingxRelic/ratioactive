extends Node
signal healed
signal death

@export var immune := false
@export var max_health := 100.0
var health := 100.0

func take_damage(dmg_amnt : float):
	if dmg_amnt != null:
		health = clampf(health-dmg_amnt, 0, max_health)
		if health == 0:
			dead()
		
func heal(heal_amnt: float):
	if heal_amnt != null:
		health = clampf(health+heal_amnt, 0, max_health)
		
func dead():
	death.emit()
	
func get_hp() -> float:
	return health
