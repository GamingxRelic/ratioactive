extends Area2D

@onready var sprite : Sprite2D = $Sprite2D as Sprite2D
@onready var portraits : Sprite2D = $"../Portraits" as Sprite2D
@onready var text_label_component = $Text_Label_Component

@onready var switch_on_sound : AudioStreamPlayer2D = $Switch_On
@onready var switch_off_sound : AudioStreamPlayer2D = $Switch_Off

var player_in_range := false

func _process(_delta) -> void:
	if Input.is_action_just_pressed("interact") and player_in_range:
		if portraits.visible:
			switch_off_sound.play()
		else:
			switch_on_sound.play()
		portraits.visible = !portraits.visible 

func _on_body_entered(body):
	if body.is_in_group("player"):
		sprite.material = World.outline
		player_in_range = true
		text_label_component.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		sprite.material = null
		player_in_range = false
		text_label_component.hide()
