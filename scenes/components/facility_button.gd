extends Button

var base: Facility
var buy_count: int = 1

func init(base_facility: Facility, buy_count_sig: Signal) -> void:
	base = base_facility
	base.facility_changed.connect(_on_facility_changed)
	buy_count_sig.connect(_on_buy_count_changed)
	update()

func _on_facility_changed(fac: Facility) -> void:
	if base == fac:
		update()

func _on_bank_change(_bank: float) -> void:
	update(false)

func _on_buy_count_changed(new_buy_count: int) -> void:
	buy_count = new_buy_count

func _on_upgrade_changed(upgrade: Upgrade) -> void:
	if upgrade.type in base.cost_upgrade_types \
	or upgrade.type in base.output_upgrade_types:
		update()

func update(should_update_text: bool = true) -> void:
	if should_update_text: update_text()
	update_disabled()

func update_text() -> void:
	if base:
		%Content.text = str(
			base.title, "\n",
			"Cost: ", Utils.format(Utils.get_total_cost(base.cost, base.cost_ratio, buy_count)), "\n",
			"Output(1): ", Utils.format(base.output), "\n",
			"Count: ", Utils.format(base.count), "\n",
			Utils.format(base.percent), "% of Total"
		)

func update_disabled() -> void:
	self.disabled = State.bank < Utils.get_total_cost(base.cost, base.cost_ratio, buy_count)
