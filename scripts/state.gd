extends Node

# Global non-Resource variables, signals, and helpers
var bank: float = 1.0
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


func format(num: float) -> String:
	const fstr: String = "%.2f"
	if is_nan(num) or is_inf(num):
		return str(num)
	elif num < 1000:
		var num_str: String = fstr % num
		if num_str.substr(len(num_str) - 2) == "00":
			# Show as integer
			return "%d" % num
		else:
			return num_str
	else:
		var power: float = floor(log(abs(num)) / log(10))
		var dec: float = num / (10 ** power)
		
		var dec_str: String = fstr % dec
		
		# Floating point arithmetic is gross
		if dec_str[0] == '0':
			# Less than 1, adjust
			power -= 1
			dec *= 10
		if len(dec_str) == 5:
			# Greater than 10, adjust
			power += 1
			dec /= 10
		
		# Update
		dec_str = fstr % dec
		
		if dec_str.substr(len(dec_str) - 2) == "00":
			# Show as integer
			return str("%d" % dec, "e%d" % power)
		else:
			return str(dec_str, "e%d" % power)
