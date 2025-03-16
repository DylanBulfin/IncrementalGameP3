extends Node


# Global non-Resource variables, signals, and helpers
var bank: float = 1e100
signal bank_changed(bank: float)
func try_debit_bank(amount: float) -> bool:
	if bank >= amount:
		bank -= amount
		bank_changed.emit(bank)
		return true
	return false
func credit_bank(amount: float) -> void:
	bank += amount
	bank_changed.emit(bank)
func init_bank(amount: float) -> void:
	bank = amount
	bank_changed.emit(bank)

var base_cspeed: float = 1.0
var cspeed_upgrade_multiplier: float:
	get:
		var cspeed_upgrade = upgrades[Upgrade.UpgradeType.CraftingSpeed as int]
		return cspeed_upgrade.multiplier
var cspeed: float:
	get: return base_cspeed * cspeed_upgrade_multiplier
signal cspeed_changed(cspeed: float)

var screens: Array[Screen]
var on_normal_screen: bool = true

var facilities: Array[Facility]
func add_facility_count(id: int, count: int) -> void:
	facilities[id].count += count
	facilities[id].facility_changed.emit(facilities[id])
func set_facility_percent(id: int, percent: float) -> void:
	facilities[id].percent = percent
	facilities[id].facility_changed.emit(facilities[id])

var upgrades: Array[Upgrade] 
func add_upgrade_count(id: int, count: int) -> void:
	upgrades[id].count += count
	upgrades[id].upgrade_changed.emit(upgrades[id])

var materials: Array[CMaterial]
func can_afford_material(material: CMaterial, n: float = 1) -> bool:
	var total_bank_cost = material.bank_cost * n
	
	var res: bool = State.bank >= material.bank_cost * n
	
	if material.input_material1_id != -1:
		res = res and State.materials[material.input_material1_id].count \
			>= material.input_material1_count * n
	if material.input_material2_id == -1:
		res = res and State.materials[material.input_material2_id].count \
			>= material.input_material2_count * n
	
	return res
func try_debit_material_cost(material: CMaterial, n: float = 1) -> bool:
	if can_afford_material(material, n):
		bank -= material.bank_cost * n
		bank_changed.emit(bank)
		
		if material.input_material1_id != -1:
			materials[material.input_material1_id].count -= material.input_material1_count * n
			materials[material.input_material1_id].material_changed.emit(materials[material.input_material1_id])
		if material.input_material2_id != -1:
			materials[material.input_material2_id].count -= material.input_material2_count * n
			materials[material.input_material2_id].material_changed.emit(materials[material.input_material2_id])
			
		return true
	return false
func refund_material_cost(material: CMaterial, n: float = 1) -> void:
	bank += material.bank_cost * n
	bank_changed.emit(bank)
	
	if material.input_material1_id != -1:
		materials[material.input_material1_id].count += material.input_material1_count * n
		materials[material.input_material1_id].material_changed.emit(materials[material.input_material1_id])
	if material.input_material2_id != -1:
		materials[material.input_material2_id].count += material.input_material2_count * n
		materials[material.input_material2_id].material_changed.emit(materials[material.input_material2_id])
func add_material_count(id: int, count: float) -> void:
	materials[id].count += count
	materials[id].material_changed.emit(materials[id])

func update_entities(collection_name: String, dicts: Array[Dictionary]) -> void:
	var collection: Array = self[collection_name]

	for i: int in range(len(collection)):
		collection[i].update_from_dict(dicts[i])
		
func _ready() -> void:
	var data: GameData = preload("res://resources/game_data.tres")
	screens = data.screens
	facilities = data.facilities
	upgrades = data.upgrades
	materials = data.materials
	
	# initialize ids
	for i: int in len(screens): screens[i].id = i
	for i: int in len(facilities): facilities[i].id = i
	for i: int in len(upgrades): 
		upgrades[i].id = i
		# Make sure id and type match
		if i != upgrades[i].type as int:
			breakpoint
	for i: int in len(materials): materials[i].id = i
	
	# Make sure user has enough for first building
	if bank < facilities[0].cost:
		bank = facilities[0].cost
	
	Saver.load_file("user://save.json")
	
	# Disable default quit behavior
	get_tree().set_auto_accept_quit(false)

# Shutdown related code
signal shutdown_initiated
var wait_signals: Array[bool] = []

func register_wait_signal(sig: Signal) -> void:
	# Add a signal which the global script will wait for before saving and exiting
	var index = len(wait_signals)
	wait_signals.append(false)
	sig.connect(func(): wait_signals[index] = true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown_initiated.emit()
		while false in wait_signals:
			# .1s delay
			await get_tree().create_timer(0.1).timeout 
		# Request to close on desktop/web
		Saver.save_file("user://save.json")
		get_tree().quit()
	if what == NOTIFICATION_APPLICATION_PAUSED:
		shutdown_initiated.emit()
		while false in wait_signals:
			# .1s delay
			await get_tree().create_timer(0.1).timeout 
		# Mobile app backgrounded
		Saver.save_file("user://save.json")
