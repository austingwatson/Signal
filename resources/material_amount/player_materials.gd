class_name PlayerMaterials
extends Resource

@export var metal := 0
@export var power_cell := 0


func add_metal(amount: int) -> void:
	metal += amount
	

func add_power_cell(amount: int) -> void:
	power_cell += amount
	

func can_afford(build_cost: BuildCost) -> bool:
	if metal >= build_cost.metal_cost and power_cell >= build_cost.power_cell_cost:
		return true
	else:
		return false


func buy(build_cost: BuildCost) -> void:
	metal -= build_cost.metal_cost
	power_cell -= build_cost.power_cell_cost
