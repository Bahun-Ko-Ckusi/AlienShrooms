extends PanelContainer

@onready var item_icon: TextureRect = $MarginContainer/ItemIcon
@onready var count_label: Label = $CountLabel

var item_id: String = ""
var item_count: int = 0


func setup(id: String, count: int) -> void:
	item_id = id
	item_count = count

	# Set count label
	count_label.text = str(count) if count > 1 else ""

	# TODO: Load actual textures based on item_id
	# For now, use placeholder colors
	var color := Color.WHITE
	if id.begins_with("spore_"):
		color = Color.YELLOW_GREEN
	elif id.begins_with("mushroom_"):
		color = Color.SADDLE_BROWN

	item_icon.modulate = color
