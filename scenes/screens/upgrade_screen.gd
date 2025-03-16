extends Control

var curr_category: int = 0
var upgrade_nodes: Array[Button]

var category_group: ButtonGroup = ButtonGroup.new()
var upgrades_group: ButtonGroup = ButtonGroup.new()

func _ready() -> void:
	var button_scene: PackedScene = preload("res://scenes/components/upgrade_button.tscn")
	
	for category_name: String in Upgrade.UpgradeCategory.keys():
		var category: int = Upgrade.UpgradeCategory[category_name]
		
		var button: Button = Button.new()
		button.text = category_name
		button.toggle_mode = true
		button.button_group = category_group
		
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if category == curr_category:
			button.set_pressed_no_signal(true)
			
		%CategoryContainer.add_child(button)
	
	for upgrade: Upgrade in State.upgrades:
		var node: Node = button_scene.instantiate()
		node.init(upgrade)
		
		node.toggle_mode = true
		node.button_group = upgrades_group
		
		node.visible = false
		upgrade_nodes.append(node)
		%UpgradesContainer.add_child(node)
	
	activate_category(curr_category)
	
	category_group.pressed.connect(_on_category_pressed)
	upgrades_group.pressed.connect(_on_upgrade_pressed)
	%BuyAllButton.pressed.connect(_on_buy_all_pressed)
	
	upgrades_group.allow_unpress = true

func _on_buy_all_pressed() -> void:
	buy_all()

func _on_category_pressed(button: BaseButton) -> void:
	var category: int = Upgrade.UpgradeCategory[button.text]
	switch_to_category(category)

func _on_upgrade_pressed(button: BaseButton) -> void:
	try_buy(button.base)
	button.set_pressed_no_signal(false)

func try_buy(upgrade: Upgrade, n: int = 1) -> bool:
	if State.try_debit_bank(upgrade.cost):
		State.add_upgrade_count(upgrade.id, n)
		return true
	return false
	

func switch_to_category(new_category: int) -> void:
	if new_category == curr_category: 
		return

	activate_category(new_category)
	curr_category = new_category

func activate_category(category: int) -> void:
	for node: Button in upgrade_nodes:
		node.visible = node.base.category as int == category

func buy_all() -> void:
	for upgrade: Upgrade in State.upgrades:
		while try_buy(upgrade): pass
