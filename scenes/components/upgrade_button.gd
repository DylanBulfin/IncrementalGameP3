extends Button

var base: Upgrade

func _ready() -> void: 
	update_text()

func init(base_upgrade: Upgrade) -> void:
	base = base_upgrade
	base.upgrade_changed.connect(_on_upgrade_changed)

func _on_upgrade_changed(upg: Upgrade) -> void:
	if base.id == upg.id:
		update_text()

func update_text() -> void:
	if base:
		%Content.text = str(
			base.title, "\n",
			"Cost(1): ", Utils.format(base.cost), "\n",
			"Multiplier: ", Utils.format(base.multiplier), "x", "\n",
			"Level: ", Utils.format(base.count)
		)
