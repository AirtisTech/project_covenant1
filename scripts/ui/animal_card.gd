extends Button

var species: AnimalSpecies
var icon_rect: ColorRect
var name_label: Label
var stats_label: Label

var drag_happened: bool = false

func setup(p_species: AnimalSpecies):
	species = p_species
	_build_ui_layout()
	name_label.text = species.species_name
	icon_rect.set_deferred("color", species.visual_color)
	var diet_icon = "🍎" if species.diet == AnimalSpecies.Diet.HERBIVORE else "🥩"
	stats_label.text = "%s | W:%.1f" % [diet_icon, species.weight]
	
	if not self.is_connected("pressed", _on_card_pressed):
		self.pressed.connect(_on_card_pressed)

func _build_ui_layout():
	if get_child_count() > 0: return
	self.custom_minimum_size = Vector2(110, 140)
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 5)
	add_child(vbox)
	
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)
	
	var icon_container = CenterContainer.new()
	icon_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon_container)
	
	icon_rect = ColorRect.new()
	icon_rect.custom_minimum_size = Vector2(60, 60)
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_container.add_child(icon_rect)
	
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 10)
	stats_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(stats_label)

func _on_card_pressed():
	if drag_happened:
		drag_happened = false
		return
		
	var canvas = get_tree().root.find_child("CanvasLayer", true, false)
	if not canvas: return
	var panel = canvas.find_child("DetailPanel", true, false)
	if not panel:
		panel = Panel.new()
		panel.set_name("DetailPanel")
		panel.set_script(load("res://scripts/ui/animal_detail_panel.gd"))
		canvas.add_child(panel)
		await get_tree().process_frame
	
	if panel.has_method("show_at_position"):
		# 获取卡片在屏幕上的精确位置
		var card_rect = get_global_rect()
		var top_center = Vector2(card_rect.position.x + card_rect.size.x / 2, card_rect.position.y)
		panel.call("show_at_position", species, top_center)

func _get_drag_data(_at_position):
	drag_happened = true
	var data = { "type": "animal_species", "species": species }
	var preview = ColorRect.new()
	preview.set_size(Vector2(species.width_in_cells * 20.0, 16))
	preview.set_deferred("color", species.visual_color)
	preview.modulate = Color(1, 1, 1, 0.5)
	set_drag_preview(preview)
	return data

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		# 使用 call_deferred 延迟重置，确保不会触发点击
		call_deferred("_reset_drag_flag")

func _reset_drag_flag():
	await get_tree().create_timer(0.1).timeout
	drag_happened = false
