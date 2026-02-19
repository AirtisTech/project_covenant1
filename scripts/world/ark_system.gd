# 预加载类
extends Node2D

const AnimalSpeciesClass = preload("res://scripts/resources/animal_species.gd")

const CELL_SIZE = Vector2(20.0, 20.0)
const GRID_WIDTH = 60
const ARK_START_X = 40.0
const DECK_Y_INDICES = [15, 17, 19]

var placed_animals: Dictionary = {} 
var cage_visuals: Dictionary = {} 
var preview_rect: ColorRect

func _ready():
	var gm = get_node_or_null("/root/GameManager")
	if gm: gm.ark_system = self
	add_to_group("ark_system")
	_setup_drag_control()
	_setup_visuals()
	_setup_preview()

# 处理点击拆除
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 获取世界坐标
		var camera = get_viewport().get_camera_2d()
		if camera:
			var world_pos = camera.get_global_transform().affine_inverse() * event.global_position
			handle_manual_click(world_pos)

func _setup_drag_control():
	var ctrl = Control.new()
	ctrl.name = "ArkDragCatcher"
	ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ctrl.set_script(load("res://scripts/world/ark_drag_handler.gd"))
	add_child(ctrl)

func _setup_visuals():
	var hull = ColorRect.new()
	hull.set_size(Vector2(1200, 160))
	hull.set_position(Vector2(ARK_START_X, 260))
	hull.color = Color(0.1, 0.08, 0.05, 1.0)
	hull.z_index = -1
	add_child(hull)
	for gy in DECK_Y_INDICES:
		var f = ColorRect.new()
		f.set_size(Vector2(1200, 2))
		f.set_position(Vector2(ARK_START_X, gy * 20))
		f.color = Color.SADDLE_BROWN
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(f)

func _setup_preview():
	preview_rect = ColorRect.new()
	preview_rect.visible = false
	preview_rect.z_index = 200
	preview_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(preview_rect)

func _pixel_to_grid(pixel_pos: Vector2) -> Vector2i:
	var gx = floor((pixel_pos.x - ARK_START_X) / CELL_SIZE.x)
	# 核心：为了扩大点击感应，我们在 Y 轴使用模糊捕捉
	var gy = round(pixel_pos.y / CELL_SIZE.y)
	return Vector2i(int(gx), int(gy))

# --- 核心：模糊点击感应算法 ---
func handle_manual_click(world_pos: Vector2):
	# 允许点击点偏离地板中心轴上下各 1 格 (20px)
	var gx = int(round((world_pos.x - ARK_START_X) / CELL_SIZE.x))
	var py = world_pos.y
	
	var target_gy = -1
	for gy in DECK_Y_INDICES:
		var floor_pixel_y = gy * 20
		# 如果点击点在甲板逻辑线上下 25 像素内，视为命中该层
		if abs(py - floor_pixel_y) < 25.0:
			target_gy = gy
			break
	
	if target_gy != -1:
		var coord = Vector2i(gx, target_gy)
		if placed_animals.has(coord):
			var species = placed_animals[coord]
			var start_coord = coord
			while placed_animals.has(start_coord + Vector2i(-1, 0)) and placed_animals[start_coord + Vector2i(-1, 0)] == species:
				start_coord.x -= 1
			_on_cage_triggered(species, start_coord)

func _on_cage_triggered(species, coord: Vector2i):
	var visual_node = cage_visuals.get(coord)
	if not visual_node: return
	
	# 反馈：高亮
	var tween = get_tree().create_tween()
	tween.tween_property(visual_node, "modulate", Color(2, 2, 2, 1), 0.1)
	tween.tween_property(visual_node, "modulate", Color(1, 1, 1, 1), 0.1)
	
	var panel = get_tree().root.find_child("DetailPanel", true, false)
	if panel:
		var screen_pos = visual_node.get_global_transform_with_canvas().origin
		var top_center = screen_pos + Vector2(visual_node.size.x * 0.5, 0)
		panel.call("show_at_position", species, top_center, true, coord)

func update_placement_preview(world_pos: Vector2, species):
	var grid_x = round((world_pos.x - ARK_START_X) / CELL_SIZE.x)
	var best_gy = -1
	for gy in DECK_Y_INDICES:
		if abs(world_pos.y - (gy * 20)) < 40.0: 
			best_gy = gy
			break
	
	if best_gy != -1:
		preview_rect.visible = true
		preview_rect.set_size(Vector2(species.width_in_cells * 20, 20))
		preview_rect.set_position(Vector2(ARK_START_X + grid_x * 20, best_gy * 20 - 18))
		if _can_place_here(Vector2i(int(grid_x), best_gy), species):
			preview_rect.color = Color(0, 1, 0, 0.4)
		else:
			preview_rect.color = Color(1, 0, 0, 0.4)
	else:
		preview_rect.visible = false

func try_place_at_world_pos(world_pos: Vector2, species) -> bool:
	var best_gy = -1
	for gy in DECK_Y_INDICES:
		if abs(world_pos.y - (gy * 20)) < 40.0: best_gy = gy
	var grid_x = round((world_pos.x - ARK_START_X) / CELL_SIZE.x)
	var snap_coord = Vector2i(int(grid_x), best_gy)
	
	if best_gy != -1 and _can_place_here(snap_coord, species):
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.call("consume_faith", species.placement_faith_cost):
			_do_place(snap_coord, species)
			return true
	return false

func _can_place_here(coord: Vector2i, species) -> bool:
	if coord.x < 0 or (coord.x + species.width_in_cells) > GRID_WIDTH: return false
	if not DECK_Y_INDICES.has(coord.y): return false
	for dx in range(species.width_in_cells):
		if placed_animals.has(coord + Vector2i(dx, 0)): return false
	return true

func _do_place(coord: Vector2i, species):
	for dx in range(species.width_in_cells):
		placed_animals[coord + Vector2i(dx, 0)] = species
	
	var v = ColorRect.new()
	v.set_size(Vector2(species.width_in_cells * 20 - 2, 18))
	v.set_position(Vector2(ARK_START_X + coord.x * 20 + 1, coord.y * 20 - 18))
	v.color = species.visual_color
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	cage_visuals[coord] = v
	
	var lm = get_node_or_null("/root/LayoutManager")
	if lm: lm.call("set_species_placed", species, true)

func remove_animal(coord: Vector2i):
	if not placed_animals.has(coord): return
	var species = placed_animals[coord]
	var start_x = coord.x
	while placed_animals.has(Vector2i(start_x - 1, coord.y)) and placed_animals[Vector2i(start_x - 1, coord.y)] == species:
		start_x -= 1
	for dx in range(species.width_in_cells):
		placed_animals.erase(Vector2i(start_x + dx, coord.y))
	if cage_visuals.has(Vector2i(start_x, coord.y)):
		cage_visuals[Vector2i(start_x, coord.y)].queue_free()
		cage_visuals.erase(Vector2i(start_x, coord.y))
	var lm = get_node_or_null("/root/LayoutManager")
	if lm: lm.call("set_species_placed", species, false)
	var gm = get_node_or_null("/root/GameManager")
	if gm: gm.call("add_faith", species.placement_faith_cost)

func get_path_to_pos(s, t): return PackedVector2Array([s, t])
