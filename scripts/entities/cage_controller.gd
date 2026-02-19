extends Button

var species: AnimalSpecies
var coord: Vector2i

func setup(p_species: AnimalSpecies, p_coord: Vector2i):
	species = p_species
	coord = p_coord
	
	var label = Label.new()
	label.text = species.species_name[0]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.add_theme_font_size_override("font_size", 8)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

# 移除内部 _pressed，改由 ArkSystem 显式连接

func _get_drag_data(_at_position):
	var drag_data = { "type": "animal_species", "species": species }
	var preview = ColorRect.new()
	preview.set_size(self.size)
	preview.color = species.visual_color
	preview.modulate.a = 0.5
	set_drag_preview(preview)
	
	var ark = get_tree().root.find_child("ArkSystem", true, false)
	if ark:
		ark.call("remove_animal", coord)
	
	return drag_data
