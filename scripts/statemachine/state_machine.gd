class_name StateMachine
extends Node2D

@export var initial_State: State
@export var show_state := false
var states := {}
var current_state: State
@onready var current_state_label := $CurrentStateLabel


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.statemachine = self
			states[child.name] = child
	enter_state(initial_State.name)
	current_state_label.visible = show_state
	

func _unhandled_input(_event: InputEvent) -> void:
	current_state.input()
	

func _physics_process(delta: float) -> void:
	current_state.update(delta)
	

func enter_state(name: String, data: Dictionary = {}) -> void:
	current_state = states[name]
	current_state.enter(data)
	current_state_label.text = name
