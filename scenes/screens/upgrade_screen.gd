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
	
	update_disabled_all()
	activate_category(curr_category)
	
	category_group.pressed.connect(_on_category_pressed)
	upgrades_group.pressed.connect(_on_upgrade_pressed)
	State.bank_changed.connect(_on_bank_changed)


func _on_category_pressed(button: BaseButton) -> void:
	var category: int = Upgrade.UpgradeCategory[button.text]
	switch_to_category(category)

func _on_upgrade_pressed(button: BaseButton) -> void:
	if State.try_debit_bank(button.base.cost):
		State.add_upgrade_count(button.base.id, 1)
		update_disabled(button.base.id)
	
	button.set_pressed_no_signal(false)

func _on_bank_changed(_bank: float) -> void:
	update_disabled_all()

func switch_to_category(new_category: int) -> void:
	if new_category == curr_category: 
		return

	activate_category(new_category)
	curr_category = new_category

func activate_category(category: int) -> void:
	for node: Button in upgrade_nodes:
		node.visible = node.base.category as int == category

func update_disabled(id: int) -> void:
	var node: Button = upgrade_nodes[id]
	node.disabled = State.bank < node.base.cost

func update_disabled_all() -> void:
	for node: Button in upgrade_nodes:
		node.disabled = State.bank < node.base.cost
