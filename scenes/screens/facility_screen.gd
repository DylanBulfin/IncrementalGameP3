extends Control

signal buy_count_changed(buy_count: int)

var group: ButtonGroup = ButtonGroup.new()
var buy_count: int = 1

var total_time: float = 0.0
var last_update: float = 0.0

var nodes: Array[Node]

func _ready() -> void:
	var button_scene: PackedScene = preload("res://scenes/components/facility_button.tscn")
	
	for facility: Facility in State.facilities:
		var node: Button = button_scene.instantiate()
		node.init(facility, buy_count_changed)
		node.toggle_mode = true
		node.button_group = group
		nodes.append(node)
		%FacilityContainer.add_child(node)

	group.pressed.connect(_on_facility_button_pressed)
	%BuyCountButton.pressed.connect(_on_buy_count_button_pressed)
	State.bank_changed.connect(_on_bank_changed)
	update_disabled_all()

func _process(delta: float) -> void:
	total_time += delta
	if total_time - last_update > 0.2:
		calculate_output(total_time - last_update)
		last_update = total_time

func _on_facility_button_pressed(button: BaseButton) -> void:
	try_buy_count(button.base, buy_count)

func _on_buy_count_button_pressed() -> void:
	increment_buy_count()

func _on_bank_changed(_bank: float) -> void:
	update_disabled_all()

func try_buy_count(facility: Facility, count: int) -> void:
	var total_cost: float = calculate_total_cost(facility, count)
	if State.try_debit_bank(total_cost):
		State.add_facility_count(facility.id, count)
		update_disabled(facility.id)

func calculate_total_cost(facility: Facility, count: int) -> float:
	return facility.cost * ((facility.cost_ratio ** count) - 1) / (facility.cost_ratio - 1)

func increment_buy_count() -> void:
	match buy_count:
		1: 
			buy_count = 10
		10: 
			buy_count = 100
		100: 
			buy_count = 1000
		1000:
			buy_count = 1
		_: breakpoint # Unrecoverable error
	%BuyCountButton.text = str(buy_count, "x")
	buy_count_changed.emit(buy_count)

func calculate_output(time: float) -> void:
	var outputs: Array[float]
	var total_output: float = 0
	
	for facility: Facility in State.facilities:
		var output: float = facility.output * facility.count * time
		outputs.append(output)
		total_output += output

	for i: int in range(len(State.facilities)):
		var percent: float = outputs[i] / total_output
		if is_nan(percent): percent = 0.0
		State.set_facility_percent(i, percent)
	
	State.credit_bank(total_output)

func update_disabled(id: int) -> void:
	nodes[id].disabled = State.bank < calculate_total_cost(nodes[id].base, buy_count)

func update_disabled_all() -> void:
	for node: Node in nodes:
		node.disabled = State.bank < calculate_total_cost(node.base, buy_count)
