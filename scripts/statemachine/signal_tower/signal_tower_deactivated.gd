extends State

@export var interactable_component: InteractableComponent
@export var sprite: Sprite2D
@export var player_materials: PlayerMaterials
@export var build_cost: BuildCost
@export var interact_positive_sound: AudioStreamPlayer
@export var interact_negative_sound: AudioStreamPlayer


func enter(_data: Dictionary) -> void:
	sprite.frame = 0


func _on_interactable_component_interacted() -> void:
	if player_materials.can_afford(build_cost):
		player_materials.buy(build_cost)
		interactable_component.interacted.disconnect(_on_interactable_component_interacted)
		interact_positive_sound.play()
		statemachine.enter_state("Built")
	else:
		interact_negative_sound.play()
