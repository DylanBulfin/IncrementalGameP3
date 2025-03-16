extends Button

var base: CMaterial

func init(base_material: CMaterial) -> void:
	base = base_material
	State.bank_changed.connect(_on_bank_changed)
	State.cspeed_changed.connect(_on_cspeed_changed)
	base.material_changed.connect(_on_material_changed)
	
	# Connect to the crafting speed upgrade
	var cspeed_upgrade = State.upgrades[Upgrade.UpgradeType.CraftingSpeed as int]
	cspeed_upgrade.upgrade_changed.connect(_on_cspeed_upgrade_changed)
	
	update()
	
func _on_bank_changed(_bank: float) -> void:
	update(false)

func _on_cspeed_changed(_speed: float) -> void:
	update()

func _on_material_changed(_mat: CMaterial) -> void:
	update()

func _on_cspeed_upgrade_changed(_upgrade: Upgrade) -> void:
	update()

func update(should_update_text: bool = true) -> void:
	if should_update_text: update_text()
	update_disabled()

func update_text() -> void:
	%MaterialLabel.text = str(
		base.title, "\n",
		"Bank Cost: ", Utils.format(base.bank_cost), "\n",
		str("Material 1: ", Utils.format(base.input_material1_count), "x ", State.materials[base.input_material1_id].title, "\n") if base.input_material1_id != -1 else "",
		str("Material 2: ", Utils.format(base.input_material2_count), "x ", State.materials[base.input_material2_id].title, "\n") if base.input_material2_id != -1 else "",
		get_time_string(), "\n",
		"Count: ", Utils.format(base.count)
	)

func update_disabled() -> void:
	self.disabled = not State.can_afford_material(base)

func get_time_string() -> String:
	if base.time_cost >= 0.25:
		return str("Crafting Time: ", Utils.format(base.time_cost), "s")
	else:
		return str(Utils.format(1 / base.time_cost), " recipes/sec")
