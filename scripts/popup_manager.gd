extends Node

func _ready() -> void:
	%Header.help_pressed.connect(
		func() -> void:
			create_help_popup(%ScreenManager.get_current_screen())
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") and %PopupContainer.visible:
		hide_popup()
	if event.is_action_pressed("help") and not %PopupContainer.visible:
		create_help_popup(%ScreenManager.get_current_screen())

func create_help_popup(screen: Screen) -> void:
	create_popup(screen.help_title, screen.help_content)

func create_popup(title: String, text: String) -> void:
	%PopupContainer.set_popup_text(title, text)
	show_popup()

func show_popup() -> void:
	if not %PopupContainer.visible:
		%PopupContainer.visible = true

func hide_popup() -> void:
	if %PopupContainer.visible:
		%PopupContainer.visible = false
