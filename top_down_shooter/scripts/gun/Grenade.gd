extends CharacterBody2D

var stopped := false
var damage := 50.0
var speed := 80.0
@onready var sprite : Sprite2D = $SpriteAnchor/Sprite2D as Sprite2D
var damage_queue : Array
@onready var explode_timer : Timer = $Explode_Timer
@onready var anim : AnimationPlayer = $AnimationPlayer

func _physics_process(_delta):
	if !stopped:
		velocity = transform.x * speed
		$SpriteAnchor.rotation += 0.1
		move_and_slide()
	
func explode() -> void:
	if damage_queue.size() > 0:
		for i in damage_queue:
			i.hurtbox_component.damage(damage, Vector2.ZERO)
	stopped = true
	anim.play("explode")

func _on_explode_timer_timeout():
	explode()

func _on_attackbox_component_body_entered(body):
	if body.is_in_group("player_can_damage") or body.is_in_group("player"):
		damage_queue.append(body)

func _on_attackbox_component_body_exited(body):
	if body.is_in_group("player_can_damage") or body.is_in_group("player"):
		damage_queue.erase(body)

func _on_hurtbox_component_body_entered(body):
	if body.is_in_group("wall") or body.is_in_group("door") or body.is_in_group("enemy"):
		explode_timer.stop()
		explode()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
