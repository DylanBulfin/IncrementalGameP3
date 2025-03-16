extends Control

signal wait_signal

var group: ButtonGroup = ButtonGroup.new()
var buttons: Array[Button]

var is_active: bool = false
var is_queued: bool = false # If it's slow and inactive but will activate once affordable
var is_fast: bool = false # If running a recipe that's too fast for tweening
var active_tween: Tween
var active_recipe: CMaterial

var last_rate: float

func _ready() -> void:
	var button_scene: PackedScene = preload("res://scenes/components/material_button.tscn")
	
	for mat: CMaterial in State.materials:
		var node: Button = button_scene.instantiate()
		node.init(mat)
		node.toggle_mode = true
		node.button_group = group
		buttons.append(node)
		%MaterialsContainer.add_child(node)
	
	group.pressed.connect(_on_pressed)
	
	%StopCraftingButton.pressed.connect(_on_stop_crafting_pressed)
	
	active_tween = get_tree().create_tween()
	active_tween.kill()
	active_recipe = State.materials[0]
	
	State.shutdown_initiated.connect(_on_shutdown_initiated)
	State.register_wait_signal(wait_signal)
	
	# Connect to the crafting speed upgrade
	var cspeed_upgrade: Upgrade = State.upgrades[Upgrade.UpgradeType.CraftingSpeed as int]
	cspeed_upgrade.upgrade_changed.connect(_on_cspeed_upgrade_changed)
	
	update_text()

func _process(delta: float) -> void:
	if is_active and is_fast:
		# Have fast-acting recipe, calculate the number of recipes
		# that could have been created in delta seconds
		var recipes_per_s: float = 1 / active_recipe.time_cost
		var max_recipes: float = recipes_per_s * delta
		
		if State.try_debit_material_cost(active_recipe, max_recipes):
			# Can afford full frame
			State.add_material_count(active_recipe.id, max_recipes)
			last_rate = max_recipes / delta
		else:
			# Calculate how many we can afford
			var max_count: float = max_recipes
			
			var bank_count: float = State.bank / active_recipe.bank_cost
			if bank_count < max_count: max_count = bank_count
			
			if active_recipe.input_material1_id != -1:
				var material1: CMaterial = State.materials[active_recipe.input_material1_id]
				var material1_count: float = material1.count / active_recipe.input_material1_count
				if material1_count < max_count: max_count = material1_count
			if active_recipe.input_material2_id != -1:
				var material2: CMaterial = State.materials[active_recipe.input_material2_id]
				var material2_count: float = material2.count / active_recipe.input_material2_count
				if material2_count < max_count: max_count = material2_count
			
			if not State.try_debit_material_cost(active_recipe, max_count):
				breakpoint # Floating point error, need to rework logic
			State.add_material_count(active_recipe.id, max_count)
			last_rate = max_count / delta
	elif not is_active and is_queued and State.can_afford_material(active_recipe):
		# We can afford another recipe, start it
		init_tween()
	
	if is_active:
		# To update time remaining or current rate
		update_text()

func _input(event: InputEvent) -> void:
	if State.on_normal_screen and self.visible and event.is_action_pressed("exit"):
		cancel_recipe()
	
func _on_pressed(button: BaseButton) -> void:
	try_activate_recipe(button.base)

func _on_shutdown_initiated() -> void:
	cancel_recipe()
	# Tell global script to go ahead and shut down
	wait_signal.emit()

func _on_stop_crafting_pressed() -> void:
	cancel_recipe()

func _on_cspeed_upgrade_changed(_upgrade: Upgrade) -> void:
	if is_active and not is_fast:
		# Need to destroy and restart this tween
		active_tween.kill()
		init_tween()

func cancel_recipe() -> void:
	if is_active and not is_fast:
		active_tween.kill()
		State.refund_material_cost(active_recipe)
	
	is_active = false
	is_fast = false
	is_queued = false
	
	%ProgressBar.value = 0
	
	buttons[active_recipe.id].set_pressed_no_signal(false)
	
	update_text()

func try_activate_recipe(mat: CMaterial) -> void:
	if is_active and mat == active_recipe:
		# No need to do anything
		return
	
	cancel_recipe()
	
	# When time is too low, tweeners are imprecise and inefficient
	if mat.time_cost <= 0.25:
		active_recipe = mat
		is_active = true
		is_fast = true
	else:
		active_recipe = mat
		if State.try_debit_material_cost(active_recipe):
			is_active = true
			init_tween()
		else:
			is_queued = true
	
	buttons[mat.id].set_pressed_no_signal(true)
	
	update_text()

func init_tween() -> void:
	active_tween = get_tree().create_tween()
	active_tween.tween_property(%ProgressBar, "value", 100, (100.0 - %ProgressBar.value) * 0.01 * active_recipe.time_cost)
	active_tween.tween_callback(complete_tweened_recipe)
	active_tween.set_loops()

func complete_tweened_recipe() -> void:
	State.add_material_count(active_recipe.id, 1)
	try_start_tweened_recipe()

func try_start_tweened_recipe() -> void:
	%ProgressBar.value = 0
	
	if not State.try_debit_material_cost(active_recipe):
		# Failed to debit resources, halt production
		active_tween.kill()
		is_active = false
		is_queued = true
		update_text()

func update_text() -> void:
	var top_text: String = "Crafting: None"
	var bot_text: String = "Select a recipe below to begin"
	
	if is_active:
		top_text = str("Crafting: ", active_recipe.title)
	elif is_queued:
		top_text = str("Queued: ", active_recipe.title)
	
	if is_queued:
		bot_text = "0/s"
	elif is_fast and is_active:
		bot_text = str(last_rate, "/s total")
	elif is_active:
		bot_text = str(active_recipe.time_cost, "s (", Utils.format((100.0 - %ProgressBar.value) * 0.01 * active_recipe.time_cost), "s left)")
	
	%ProgressBarLabel.text = str(top_text, "\n", bot_text)
