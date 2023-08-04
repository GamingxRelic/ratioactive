extends Area2D

@export var price : int = 0
var player_in_range := false

signal purchased
signal failed_purchase

signal player_entered_range
signal player_exited_range

func _process(_delta) -> void:
	if player_in_range and Input.is_action_just_pressed("interact") and World.pickup_queue.size() == 0:
		purchase()

func purchase() -> void:
	if World.player_points >= price:
		World.UI.subtract_points(price)
		World.player_points -= price
		purchased.emit()
	else:
		failed_purchase.emit()

func refund() -> void:
	World.player_points += price
	World.UI.update_points()

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_entered_range.emit()
		return

func _on_body_exited(body) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_exited_range.emit()
		return
