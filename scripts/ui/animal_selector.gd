extends Control

@onready var card_container = $ScrollContainer/HBoxContainer

# 记录 物种 -> 卡片节点 的映射
var card_nodes: Dictionary = {}

func _ready():
	call_deferred("_build_menu")
	
	# 连接状态改变信号
	var lm = get_node_or_null("/root/LayoutManager")
	if lm:
		lm.connect("species_status_changed", _on_species_status_changed)

func _build_menu():
	if not card_container: return
	for child in card_container.get_children(): child.queue_free()
	card_nodes.clear()
	
	var lm = get_node_or_null("/root/LayoutManager")
	if not lm: return
	
	var list = lm.get("species_list")
	for species in list:
		var card = _create_card(species)
		card_container.add_child(card)
		card_nodes[species] = card
		
		# 初始化显示状态
		card.visible = not species.is_placed

func _create_card(species: AnimalSpecies) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(110, 140)
	btn.set_script(load("res://scripts/ui/animal_card.gd"))
	btn.call_deferred("setup", species)
	return btn

# --- 核心：实时刷新菜单 ---
func _on_species_status_changed(species: AnimalSpecies, is_placed: bool):
	if card_nodes.has(species):
		# 如果已在船上，隐藏卡片；如果被拆除，显示卡片
		card_nodes[species].visible = not is_placed