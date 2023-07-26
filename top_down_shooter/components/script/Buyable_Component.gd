extends Area2D

@export var price : int = 0
var player_in_range := false

signal purchased
signal failed_purchase

signal player_entered_range
signal player_exited_range

func _process(_delta):
	if player_in_range:
		if Input.is_action_just_pressed("interact"):
			purchase()

func purchase():
	if World.player_points >= price:
		World.UI.subtract_points(price)
		World.player_points -= price
		purchased.emit()
	else:
		failed_purchase.emit()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_entered_range.emit()
		return

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_exited_range.emit()
		return
