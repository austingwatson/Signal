extends State

signal back_alive

@export var animated_sprite: AnimatedSprite2D
@export var health: HealthResource
@export var hurtbox_collision: CollisionShape2D
@export var hurtbox: HurtBox
@export var character_movement: CharacterMovementComponent
@export var footstep_sound: AudioStreamPlayer


func enter(_data: Dictionary) -> void:
	footstep_sound.stop()
	character_movement.set_direction(Vector2.ZERO)
	hurtbox_collision.set_deferred("disabled", true)
	animated_sprite.play("knockedout")
	await get_tree().create_timer(health.dead_body_timer).timeout
	hurtbox_collision.set_deferred("disabled", false)
	hurtbox.heal(10000)
	back_alive.emit()
	statemachine.enter_state("Idle")
