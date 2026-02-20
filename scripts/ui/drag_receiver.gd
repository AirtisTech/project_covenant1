extends Control

func _gui_input(event):
	# 核心：将 UI 点击直接转发给方舟系统
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ark = get_tree().root.find_child("ArkSystem", true, false)
		if ark:
			# 将 UI 坐标转换为世界坐标
			var world_pos = get_viewport().get_canvas_transform().affine_inverse() * (event.position + global_position)
			ark.handle_manual_click(world_pos)

func _can_drop_data(at_position, data):
	if data is Dictionary and data.get("type") == "animal_species":
		var species = data.get("species")
		var world_pos = get_viewport().get_canvas_transform().affine_inverse() * at_position
		var ark = get_tree().root.find_child("ArkSystem", true, false)
		if ark:
			ark.update_placement_preview(world_pos, species)
		return true
	return false

func _drop_data(at_position, data):
	var species = data.get("species")
	if species:
		var world_pos = get_viewport().get_canvas_transform().affine_inverse() * at_position
		var ark = get_tree().root.find_child("ArkSystem", true, false)
		if ark:
			ark.try_place_at_world_pos(world_pos, species)