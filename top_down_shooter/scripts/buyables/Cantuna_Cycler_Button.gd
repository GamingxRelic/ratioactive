extends Node2D

var player_in_range := false
@onready var sprite : Sprite2D = $Sprite2D
@onready var text_label_component = $Text_Label_Component
@onready var buyable_component = $Buyable_Component

func _ready() -> void:
	text_label_component.set_text("[E] - Reroll Weapons \n$1000")

func _on_buyable_component_player_entered_range() -> void:
	text_label_component.show()
	sprite.material = World.outline

func _on_buyable_component_player_exited_range() -> void:
	text_label_component.hide()
	sprite.material = null
	
func _on_buyable_component_purchased():
	World.cantuna_cycle_weapon.emit()
