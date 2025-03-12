extends Control

var base: Facility

func _ready() -> void: 
	update_text()

func init(base_facility: Facility) -> void:
	base = base_facility
	base.facility_changed.connect(_on_facility_changed)

func _on_facility_changed(fac: Facility) -> void:
	if base == fac:
		update_text()

func update_text() -> void:
	if base:
		%Content.text = str(
			base.title, "\n",
			"Cost(1): ", base.cost, "\n",
			"Output(1): ", base.output, "\n",
			"Count: ", base.count, "\n",
			"% Total: ", 100.0
		)
