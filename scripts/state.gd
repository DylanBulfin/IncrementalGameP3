extends Node

# Global non-Resource variables, signals, and helpers
var bank: float
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

var screens: Array[Screen]

var facilities: Array[Facility]
func add_facility_count(id: int, count: int) -> void:
	facilities[id].count += count
	facilities[id].facility_changed.emit(facilities[id])
func set_facility_percent(id: int, percent: float) -> void:
	facilities[id].percent = percent
	facilities[id].facility_changed.emit(facilities[id])

var upgrades: Array[Upgrade] 
var materials: Array[CMaterial]

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
	for i: int in len(upgrades): upgrades[i].id = i
	for i: int in len(materials): materials[i].id = i
	
	# Make sure user has enough for first building
	if bank < facilities[0].cost:
		bank = facilities[0].cost
	
	
	Saver.load_file("user://save.json")
	
	# Disable default quit behavior
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Request to close on desktop/web
		Saver.save_file("user://save.json")
		get_tree().quit()
	if what == NOTIFICATION_APPLICATION_PAUSED:
		# Mobile app backgrounded
		Saver.save_file("user://save.json")
