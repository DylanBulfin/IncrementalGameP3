extends Resource
class_name CMaterial

@warning_ignore("unused_signal")
signal material_changed(material: CMaterial)

var id: int
@export var title: String
@export var bank_cost: float
@export var count: int = 0

# -1 means N/A
@export var input_material1_id: int = -1
@export var input_material2_id: int = -1

@export var input_material1_count: int = 0
@export var input_material2_count: int = 0

func to_dict() -> Dictionary:
	# Count is the only non-derived field that can change during the game
	return {"count": count}

func update_from_dict(dict: Dictionary) -> bool:
	if not "count" in dict:
		return false
		
	count = dict["count"]
	return true
