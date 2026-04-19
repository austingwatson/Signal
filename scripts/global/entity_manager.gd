extends Node

var enemies := Node2D.new()
var reservations := {}

func _ready() -> void:
	add_child(enemies)
	
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	reservations.clear()
	
	for enemy in enemies.get_children():
		if not enemy.get_node("PathFinderComponent").use_flowfield:
			continue
		
		var desired = enemy.get_node("PathFinderComponent").request_next_tile()
		if not reservations.has(desired):
			reservations[desired] = [enemy]
		else:
			reservations[desired].append(enemy)
	
	for tile in reservations.keys():
		var list = reservations[tile]
		
		if list.size() == 1:
			list[0].get_node("PathFinderComponent").final_tile = tile
		else:
			var winner = list[randi() % list.size()]
			winner.get_node("PathFinderComponent").final_tile = tile
			
			for other in list:
				if other != winner:
					other.get_node("PathFinderComponent").find_fallback_tile(reservations)
	
	for enemy in enemies.get_children():
		enemy.get_node("PathFinderComponent").apply_reserved_tile()


func add_entity(entity: Node) -> void:
	add_child(entity)
	

func add_enemy(enemy: Node) -> void:
	enemies.add_child(enemy)
