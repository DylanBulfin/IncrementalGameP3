extends HBoxContainer

@warning_ignore_start("unused_signal")
signal help_pressed
signal side_menu_pressed
@warning_ignore_restore("unused_signal")

func _ready() -> void:
	update_text()
	State.bank_changed.connect(_on_bank_changed)
	
	%SideMenuButton.pressed.connect(func() -> void: side_menu_pressed.emit())
	%HelpButton.pressed.connect(func() -> void: Utils.exec_event("help"))

func _on_bank_changed(_bank: float) -> void:
	update_text()

func update_text() -> void:
	%HeaderLabel1.text = str("Bank: ", Utils.format(State.bank))
