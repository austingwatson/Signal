extends State

@export var tower: Node
@export var sprite: Sprite2D
@export var interact_component_shape: CollisionShape2D
@export var placeable_zone_shape: CollisionShape2D
@export var hurt_box_shape: CollisionShape2D


func enter(_data: Dictionary) -> void:
	sprite.frame = 5
	
	interact_component_shape.set_deferred("disabled", true)
	placeable_zone_shape.set_deferred("disabled", true)
	hurt_box_shape.set_deferred("disabled", true)
	
	GlobalSignals.call_deactivate_tower(tower)
	tower.add_to_group("destroyed_tower")
	tower.remove_from_group("tower_on")
