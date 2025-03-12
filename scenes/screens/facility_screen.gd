extends Control

func _ready() -> void:
	var button_scene = preload("res://scenes/components/facility_button.tscn")
	
	for facility in State.facilities:
		var node = button_scene.instantiate()
		node.init(facility)
		%FacilityContainer.add_child(node)
