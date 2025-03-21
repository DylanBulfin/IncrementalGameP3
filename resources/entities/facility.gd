extends Resource
class_name Facility

@warning_ignore("unused_signal")
signal facility_changed(facility: Facility)

var id: int
@export var title: String
@export var base_cost: float
@export var base_output: float

@export var cost_ratio: float = 1.5
@export var count: int = 0
@export var tens_multi: float = 2.0
@export var hundreds_multi: float = 20.0

@export var output_upgrade_types: Array[Upgrade.UpgradeType] = \
[Upgrade.UpgradeType.AllFacilityOutput]
@export var cost_upgrade_types: Array[Upgrade.UpgradeType] = \
[Upgrade.UpgradeType.AllFacilityCost]
@export var output_material_types: Array[int]
var percent: float = 0.0 # Percentage of output this facility makes up

# Multipliers from various systems
var count_multi: float:
	get:
		# The integer division is intentional
		var hundreds: int = count / 100
		var tens: int = (count / 10) - hundreds
		
		return (hundreds_multi ** hundreds) \
			 * (tens_multi ** tens)

var upgrades_multi: float:
	get: return output_upgrade_types\
		.map(func(t: int) -> float: return State.upgrades[t].multiplier)\
		.reduce(func(acc: float, next: float) -> float: return acc * next)

var materials_multi: float:
	get: return output_material_types\
		.map(func(m: int) -> float: return State.materials[m].facility_multiplier)\
		.reduce(func(acc: float, next: float) -> float: return acc + next)\
		if len(output_material_types) > 0 else 1.0

var cost_count_multi: float:
	get: return cost_ratio ** count

# This is more of a divisor
var cost_upgrades_multi: float:
	get: return cost_upgrade_types\
		.map(func(t: int) -> float: return State.upgrades[t].multiplier)\
		.reduce(func(acc: float, next: float) -> float: return acc * next)
			

var cost: float:
	get: return \
		  base_cost \
		* cost_count_multi \
		* cost_upgrades_multi

var output: float:
	get: return \
		  base_output \
		* count_multi \
		* upgrades_multi \
		* materials_multi

func to_dict() -> Dictionary:
	# Count is the only non-derived field that can change during the game
	return {"count": count}

func update_from_dict(dict: Dictionary) -> bool:
	if not "count" in dict:
		return false
		
	count = dict["count"]
	return true
