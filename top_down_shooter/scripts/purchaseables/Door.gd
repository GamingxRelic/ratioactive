extends StaticBody2D

@export var price := 0
@onready var buyable_component = $Buyable_Component

func _ready():
	buyable_component.price = price

func _on_purchaseable_component_purchased():
	self.queue_free()

func _on_purchaseable_component_failed_purchase():
	print("failed door purchase")
