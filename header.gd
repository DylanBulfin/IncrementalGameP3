extends HBoxContainer

func _ready() -> void:
	update_text()
	State.bank_changed.connect(_on_bank_changed)

func _on_bank_changed(_bank: float) -> void:
	update_text()

func update_text() -> void:
	%HeaderLabel1.text = str("Bank: ", State.format(State.bank))
