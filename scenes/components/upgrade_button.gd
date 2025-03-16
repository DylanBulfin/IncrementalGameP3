extends Button

var base: Upgrade

func init(base_upgrade: Upgrade) -> void:
	base = base_upgrade
	base.upgrade_changed.connect(_on_upgrade_changed)
	State.bank_changed.connect(_on_bank_changed)
	update()

func _on_upgrade_changed(upg: Upgrade) -> void:
	if base.id == upg.id:
		update()

func _on_bank_changed(_bank: float) -> void:
	update(false)

func update(should_update_text: bool = true) -> void:
	if should_update_text: update_text()
	update_disabled()

func update_text() -> void:
	if base:
		%Content.text = str(
			base.title, "\n",
			"Cost(1): ", Utils.format(base.cost), "\n",
			"Multiplier: ", Utils.format(base.multiplier), "x", "\n",
			"Level: ", Utils.format(base.count)
		)

func update_disabled() -> void:
	self.disabled = State.bank < base.cost
