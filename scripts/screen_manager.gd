extends Node

var curr_screen: int = 0
var screen_nodes: Array[Node]

func _ready() -> void:
	for screen: Screen in State.screens:
		%SideMenu.add_item(screen.title)
		var node: Node = Screen.scenes[screen.id].instantiate()
		node.visible = false
		screen_nodes.append(node)
		%ScreenContainer.add_child(node)
	
	screen_nodes[curr_screen].visible = true

	%SideMenu.item_selected.connect(
		func(id: int) -> void: 
			if id <= 9:
				Utils.exec_event(str("screen", id + 1))
			else: breakpoint # Unrecoverable error
	)
	
	%Header.side_menu_pressed.connect(
		func() -> void: Utils.exec_event("sidemenu")
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") and not %PopupContainer.visible:
		close_side_menu()
	elif event.is_action_pressed("sidemenu"):
		open_side_menu()
	else: for i: int in range(10):
		if event.is_action_pressed(str("screen", i + 1)):
			switch_to_screen(i)
	

func open_side_menu() -> void:
	if not %SideMenu.visible:
		%SideMenu.visible = true

func close_side_menu() -> void:
	if %SideMenu.visible:
		%SideMenu.visible = false

func switch_to_screen(id: int) -> void:
	if curr_screen != id:
		screen_nodes[curr_screen].visible = false # "deactivate" old screen
		screen_nodes[id].visible = true
		
		curr_screen = id
	
	close_side_menu()

func get_current_screen() -> Screen:
	return State.screens[curr_screen]
