extends Node

const collections_to_save: Array[String] = \
[
	"facilities", 
	"upgrades", 
	"materials"
]

func save_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	var dict: Dictionary = {
		"bank": State.bank,
	}
	for collection_name: String in collections_to_save:
		dict[collection_name] = State[collection_name].map(func(d: Resource) -> Dictionary: return d.to_dict())
	
	file.store_line(JSON.stringify(dict))
	file.close()

func load_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	var dict: Dictionary = JSON.parse_string(file.get_as_text())
	
	for collection_name: String in collections_to_save:
		var collection: Array = dict[collection_name]
		
		for i: int in range(len(collection)):
			var entity_data: Dictionary = collection[i]
			var entity: Variant = State[collection_name][i]
			
			for field: String in entity_data.keys():
				entity.update_from_dict(entity_data)
	
	State.init_bank(dict["bank"])
	
	return true
