extends StaticBody2D

@export var price := 0
@onready var buyable_component = $Buyable_Component  
@onready var text_label_component : Control = $Text_Label_Component
@onready var sprite = $Sprite2D as Sprite2D
@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var col_shape = self.find_child("CollisionShape2D")

func _ready():
	buyable_component.price = price
	text_label_component.set_text("[E] - $" +str(price))

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "remove_door":
		self.queue_free()

func _on_buyable_component_player_entered_range():
	text_label_component.show()
	sprite.material = World.outline

func _on_buyable_component_player_exited_range():
	text_label_component.hide()
	sprite.material = null

func _on_buyable_component_purchased():
	World.kaching_sound.emit()
	anim_player.play("remove_door")
	col_shape.disabled = true
