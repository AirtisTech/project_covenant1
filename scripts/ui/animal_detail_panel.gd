extends Control

# 预加载类
const AnimalSpeciesClass = preload("res://scripts/resources/animal_species.gd")

var name_label: Label
var desc_label: Label
var stats_label: Label
var remove_btn: Button
var vbox: VBoxContainer
var bg_rect: ColorRect

var current_coord: Vector2i

func _ready():
	_build_ui_internally()
	self.visible = false

func _build_ui_internally():
	# 手动构建不透明背景
	bg_rect = ColorRect.new()
	bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = Color(0.05, 0.05, 0.05, 1.0) # 纯黑
	add_child(bg_rect)
	
	# 边框视觉
	var frame = ReferenceRect.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.border_color = Color.GOLDENROD
	frame.border_width = 2
	frame.editor_only = false # 确保运行时可见
	add_child(frame)
	
	vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 15
	vbox.offset_right = -15
	vbox.offset_top = 15
	vbox.offset_bottom = -15
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(name_label)
	
	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(250, 0)
	desc_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_label)
	
	stats_label = Label.new()
	stats_label.add_theme_color_override("font_color", Color.CYAN)
	stats_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(stats_label)
	
	remove_btn = Button.new()
	remove_btn.text = " [ 拆除此动物棚 ] "
	remove_btn.add_theme_color_override("font_color", Color.RED)
	remove_btn.pressed.connect(_on_remove_pressed)
	vbox.add_child(remove_btn)

func show_at_position(species, target_top_center: Vector2, is_built: bool = false, coord: Vector2i = Vector2i.ZERO):
	name_label.text = species.species_name
	desc_label.text = species.description
	var diet = "🌿素食" if species.diet == AnimalSpeciesClass.Diet.HERBIVORE else "🥩肉食"
	stats_label.text = "格数:%d | 重量:%.1f | %s" % [species.width_in_cells, species.weight, diet]
	
	remove_btn.visible = is_built
	current_coord = coord
	
	# 自适应大小
	self.set_size(Vector2(280, 0))
	await get_tree().process_frame 
	var real_h = vbox.get_combined_minimum_size().y + 30
	self.set_size(Vector2(280, real_h))
	
	var final_pos = target_top_center - Vector2(size.x * 0.5, size.y + 20.0)
	var screen_w = get_viewport().get_visible_rect().size.x
	final_pos.x = clamp(final_pos.x, 10.0, screen_w - size.x - 10.0)
	
	self.set_global_position(final_pos)
	self.visible = true
	self.modulate.a = 1.0

func _on_remove_pressed():
	var ark = get_tree().root.find_child("ArkSystem", true, false)
	if ark:
		ark.call("remove_animal", current_coord)
		self.visible = false

func _input(event):
	if self.visible and event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			self.visible = false