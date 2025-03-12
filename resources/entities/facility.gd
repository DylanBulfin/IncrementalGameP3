extends Resource
class_name Facility

signal facility_changed(facility: Facility)

var id: int
@export var title: String
@export var base_cost: float
@export var base_output: float
@export var cost_ratio: float
@export var count: int
@export var tens_multi: float = 2.0
@export var hundreds_multi: float = 20.0

# Multipliers from various systems
var count_multi: float:
	get:
		var hundreds: int = count / 100 
		var tens: int = (count / 10) - hundreds
		
		return (hundreds_multi ** hundreds) \
			 * (tens_multi ** tens)

var upgrades_multi: float:
	get: return 1.0 # TODO Fix this when upgrades implemented

var materials_multi: float:
	get: return 1.0 # TODO Fix this when crafting implemented

var cost_count_multi: float:
	get: return cost_ratio ** count

# This is more of a divisor
var cost_upgrades_multi: float:
	get: return 1.0 # TODO Fix this when upgrades implemented

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
