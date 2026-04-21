extends State

@export var animated_sprite: AnimatedSprite2D
var ups := ["idle_up", "move_up"]
@onready var ouch := $Ouch


func enter(_data: Dictionary) -> void:
	if ups.has(animated_sprite.animation):
		animated_sprite.play("hurt_up")
	else:
		animated_sprite.play("hurt")
		
	ouch.play()
	
	await get_tree().create_timer(0.05).timeout
	statemachine.enter_state("Idle")
