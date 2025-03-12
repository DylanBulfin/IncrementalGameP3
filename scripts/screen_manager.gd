extends Node

var curr_screen: int = 0
var screen_nodes: Array[Node]

func _ready() -> void:
	for screen in State.screens:
		%SideMenu.add_item(screen.title)
		var node = Screen.scenes[screen.id].instantiate()
		screen_nodes.append(node)
		%ScreenContainer.add_child(node)

	%SideMenu.item_selected.connect(switch_to_screen)

func switch_to_screen(id: int) -> void:
	if curr_screen == id: return
	
	%SideMenu.visible = false
	
	# "deactivate" old screen
	screen_nodes[curr_screen].visible = false
	screen_nodes[id].visible = true
	
	curr_screen = id
