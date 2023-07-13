extends StaticBody2D

@export var price := 0
@onready var buyable_component = $Buyable_Component  
var text_label_component

func _ready():
	buyable_component.price = price
	text_label_component = $Text_Label_Component
	text_label_component.set_text(str(price))

func _on_purchaseable_component_purchased():
	self.queue_free()

func _on_purchaseable_component_failed_purchase():
	#print("failed door purchase")
	return


