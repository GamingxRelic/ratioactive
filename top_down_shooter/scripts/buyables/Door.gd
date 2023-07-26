extends StaticBody2D

@export var price := 0
@onready var buyable_component = $Buyable_Component  
@onready var text_label_comp : Control = $Text_Label_Component
@onready var sprite = $Sprite2D as Sprite2D
@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var col_shape = $CollisionShape2D as CollisionShape2D

func _ready():
	buyable_component.price = price
	text_label_comp.set_text(str(price))

func _on_purchaseable_component_purchased():
	anim_player.play("remove_door")
	col_shape.disabled = true

func _on_purchaseable_component_failed_purchase():
	#print("failed door purchase")
	return

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "remove_door":
		self.queue_free()
