extends ColorRect

signal exit_button_pressed

func _ready() -> void:
	%ExitButton.pressed.connect(func() -> void: Utils.exec_event("exit"))

func set_popup_text(title: String, text: String) -> void:
	%PopupTitle.text = title
	%PopupText.text = text
