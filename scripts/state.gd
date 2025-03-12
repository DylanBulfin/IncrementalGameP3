extends Node

var screens: Array[Screen]

var facilities: Array[Facility]
var upgrades: Array[Upgrade] 
var materials: Array[CMaterial]

func _ready() -> void:
	var data: GameData = preload("res://resources/game_data.tres")
	screens = data.screens
	facilities = data.facilities
	upgrades = data.upgrades
	materials = data.materials
	
	# initialize ids
	for i in len(screens): screens[i].id = i
	for i in len(facilities): facilities[i].id = i
	for i in len(upgrades): upgrades[i].id = i
	for i in len(materials): materials[i].id = i
