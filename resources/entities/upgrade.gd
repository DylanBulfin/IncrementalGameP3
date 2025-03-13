extends Resource
class_name Upgrade

enum UpgradeType {
	Facility1,
	Facility2,
	Facility3,
	Facility4,
	Facility5,
	Facility6,
	Facility7,
	Facility8,
	AllFacilityOutput,
	AllFacilityCost,
	
	CraftingSpeed,
	CraftingOutput
}

enum UpgradeCategory {
	Facilities,
	Crafting,
}

@warning_ignore("unused_signal")
signal upgrade_changed(upgrade: Upgrade)

var id: int
@export var title: String
@export var base_cost: float
@export var type: UpgradeType
@export var count: int = 0

@export var cost_ratio: float = 10.0
@export var multiplier: float = 2.0

var category: UpgradeCategory:
	get:
		match type:
			UpgradeType.Facility1,\
			UpgradeType.Facility2,\
			UpgradeType.Facility3,\
			UpgradeType.Facility4,\
			UpgradeType.Facility5,\
			UpgradeType.Facility6,\
			UpgradeType.Facility7,\
			UpgradeType.Facility8,\
			UpgradeType.AllFacilityOutput,\
			UpgradeType.AllFacilityCost:
				return UpgradeCategory.Facilities
			UpgradeType.CraftingSpeed,\
			UpgradeType.CraftingOutput:
				return UpgradeCategory.Crafting
			_: breakpoint # Unrecoverable error
		# Should be unreachable
		@warning_ignore("int_as_enum_without_match")
		return -1 as UpgradeCategory

func to_dict() -> Dictionary:
	# Count is the only non-derived field that can change during the game
	return {"count": count}

func update_from_dict(dict: Dictionary) -> bool:
	if not "count" in dict:
		return false
		
	count = dict["count"]
	return true
