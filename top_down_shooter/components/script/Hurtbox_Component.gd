extends Area2D
signal took_damage

@export var knockback_resistance := 1.0

func damage(dmg_amnt : float, knockback_amnt : Vector2):
#	print("took ", dmg_amnt, "dmg and ", (knockback_amnt - knockback_resistance), "knockback")
	took_damage.emit(dmg_amnt, (knockback_amnt / knockback_resistance))
