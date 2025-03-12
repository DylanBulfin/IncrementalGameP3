extends Control

var base: Facility
var buy_count: int = 1

func _ready() -> void: 
	update_text()

func init(base_facility: Facility, buy_count_sig: Signal) -> void:
	base = base_facility
	base.facility_changed.connect(_on_facility_changed)
	buy_count_sig.connect(_on_buy_count_changed)

func _on_facility_changed(fac: Facility) -> void:
	if base == fac:
		update_text()

func _on_buy_count_changed(new_buy_count: int) -> void:
	buy_count = new_buy_count

func update_text() -> void:
	if base:
		%Content.text = str(
			base.title, "\n",
			"Cost: ", State.format(base.cost * buy_count), "\n",
			"Output(1): ", State.format(base.output), "\n",
			"Count: ", State.format(base.count), "\n",
			State.format(base.percent), "% of Total"
		)
