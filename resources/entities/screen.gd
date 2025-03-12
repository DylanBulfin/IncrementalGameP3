extends Resource
class_name Screen

var id: int
@export var title: String
@export var help_title: String
@export var help_content: String

static var scenes = [
	preload("res://scenes/screens/facility_screen.tscn")
]
