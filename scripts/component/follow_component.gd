class_name FollowComponent
extends Node2D

@export var parent: Node2D
@export var offset := Vector2.ZERO
@export var detection_component: DetectionComponent
@export var player_materials: PlayerMaterials
@export_file("*.tres") var build_cost_path: String
var build_cost: BuildCost
var entity: Node2D = null
var in_tower_range := false
var tower = null


func _ready() -> void:
	build_cost = load(build_cost_path)
	detection_component.disable()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ping"):
		refund()
	
	if not in_tower_range:
		return
	
	if Input.is_action_just_pressed("shoot"):
		parent.modulate = Color.WHITE
		detection_component.enable()
		
		var cable := preload("res://scenes/effect/power_cable.tscn").instantiate()
		cable.set_cable_points(global_position, tower.get_parent().get_node("TowerBase").global_position)
		EntityManager.add_entity(cable)
		
		queue_free()


func _physics_process(delta: float) -> void:
	if entity == null:
		return
		
	parent.global_position = entity.global_position + offset.rotated(entity.global_rotation)


func refund() -> void:
	player_materials.refund(build_cost)
	parent.queue_free()


func follow(entity: Node2D) -> void:
	self.entity = entity


func _on_possible_placement_area_entered(area: Area2D) -> void:
	tower = area
	in_tower_range = true


func _on_possible_placement_area_exited(_area: Area2D) -> void:
	in_tower_range = false
