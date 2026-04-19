extends State


func _on_interactable_component_interacted() -> void:
	statemachine.enter_state("Activated")
