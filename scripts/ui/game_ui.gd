extends Control

@onready var spore_label: Label = $TopBar/SporeCount/SporeLabel
@onready var mushroom_label: Label = $TopBar/MushroomCount/MushroomLabel
@onready var location_label: Label = $TopBar/LocationLabel
@onready var interact_hint: Label = $BottomBar/InteractHint
@onready var inventory_btn: Button = $BottomBar/InventoryBtn
@onready var inventory_panel: PanelContainer = $InventoryPanel
@onready var inventory_grid: GridContainer = $InventoryPanel/InventoryContent/InventoryGrid
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var npc_name_label: Label = $DialoguePanel/DialogueContent/NPCName
@onready var dialogue_text: RichTextLabel = $DialoguePanel/DialogueContent/DialogueText
@onready var dialogue_options: VBoxContainer = $DialoguePanel/DialogueContent/DialogueOptions


func _ready() -> void:
	PlayerData.spores_changed.connect(_on_spores_changed)
	PlayerData.mushrooms_changed.connect(_on_mushrooms_changed)
	PlayerData.inventory_changed.connect(_on_inventory_changed)

	update_spore_display()
	update_mushroom_display()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()


func update_spore_display() -> void:
	spore_label.text = "Spores: %d" % PlayerData.get_total_spores()


func update_mushroom_display() -> void:
	mushroom_label.text = "Mushrooms: %d" % PlayerData.get_total_mushrooms()


func set_location(location_name: String) -> void:
	location_label.text = location_name


func show_interact_hint(show: bool, text: String = "[E] Interact") -> void:
	interact_hint.visible = show
	interact_hint.text = text


func toggle_inventory() -> void:
	inventory_panel.visible = not inventory_panel.visible
	if inventory_panel.visible:
		refresh_inventory()


func refresh_inventory() -> void:
	# Clear existing slots
	for child in inventory_grid.get_children():
		child.queue_free()

	# Add spore items
	for spore_type in PlayerData.spores:
		var count: int = PlayerData.spores[spore_type]
		add_inventory_item("spore_%s" % spore_type, count)

	# Add mushroom items
	for mushroom_type in PlayerData.mushrooms:
		var count: int = PlayerData.mushrooms[mushroom_type]
		add_inventory_item("mushroom_%s" % mushroom_type, count)


func add_inventory_item(item_id: String, count: int) -> void:
	var slot_scene := preload("res://scenes/ui/inventory_slot.tscn")
	var slot := slot_scene.instantiate()
	slot.setup(item_id, count)
	inventory_grid.add_child(slot)


func show_dialogue(npc: String, text: String, options: Array = []) -> void:
	npc_name_label.text = npc
	dialogue_text.text = text

	# Clear old options
	for child in dialogue_options.get_children():
		child.queue_free()

	# Add new options
	for i in options.size():
		var option: Dictionary = options[i]
		var btn := Button.new()
		btn.text = option.get("text", "...")
		btn.pressed.connect(_on_dialogue_option_pressed.bind(i))
		dialogue_options.add_child(btn)

	dialogue_panel.visible = true
	GameManager.change_state(GameManager.GameState.DIALOGUE)


func hide_dialogue() -> void:
	dialogue_panel.visible = false
	GameManager.change_state(GameManager.GameState.PLAYING)


func _on_dialogue_option_pressed(index: int) -> void:
	hide_dialogue()


func _on_spores_changed(_new_count: int) -> void:
	update_spore_display()


func _on_mushrooms_changed(_new_count: int) -> void:
	update_mushroom_display()


func _on_inventory_changed() -> void:
	if inventory_panel.visible:
		refresh_inventory()
