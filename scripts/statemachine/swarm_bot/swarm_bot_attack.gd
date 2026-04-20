extends State

@export var swarm_bot: Node2D
@export var damage: Damage
@export var animated_sprite: AnimatedSprite2D


func enter(data: Dictionary) -> void:
	var target: HurtBox = data["target"]
	target.take_damage(damage.damage)
	set_animation(target.global_position)
	await get_tree().create_timer(damage.cooldown).timeout
	if statemachine.current_state.name == "Attack":
		statemachine.enter_state("Idle")
	

func set_animation(target: Vector2) -> void:
	var dir := (target - swarm_bot.global_position).normalized()
	if dir.y < -0.2:
		animated_sprite.play("attack_up")
	else:
		animated_sprite.play("attack")
	if dir.x < 0:
		animated_sprite.flip_h = true
	elif dir.x > 0:
		animated_sprite.flip_h = false
