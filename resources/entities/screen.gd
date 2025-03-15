extends Resource
class_name Screen

var id: int
@export var title: String
@export var help_title: String
@export var help_content: String

static var scenes: Array[PackedScene] = [
	preload("res://scenes/screens/facility_screen.tscn"),
	preload("res://scenes/screens/upgrade_screen.tscn"),
	preload("res://scenes/screens/dummy_screen.tscn"),
	preload("res://scenes/screens/dummy_screen.tscn"),
	preload("res://scenes/screens/dummy_screen.tscn"),
	
	preload("res://scenes/screens/dummy_screen.tscn"),
	preload("res://scenes/screens/dummy_screen.tscn"),
	preload("res://scenes/screens/dummy_screen.tscn"),
	preload("res://scenes/screens/dummy_screen.tscn"),
	preload("res://scenes/screens/dummy_screen.tscn"),
]
