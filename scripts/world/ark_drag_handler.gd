extends Control

func _can_drop_data(at_position, data):
	if data is Dictionary and data.get("type") == "animal_species":
		var species = data.get("species")
		var ark = get_parent()
		if ark:
			# 转换屏幕坐标到世界坐标
			var camera = get_viewport().get_camera_2d()
			var world_pos = camera.get_global_transform().affine_inverse() * at_position
			ark.update_placement_preview(world_pos, species)
		return true
	return false

func _drop_data(at_position, data):
	var species = data.get("species")
	if species:
		var ark = get_parent()
		if ark:
			# 转换屏幕坐标到世界坐标
			var camera = get_viewport().get_camera_2d()
			var world_pos = camera.get_global_transform().affine_inverse() * at_position
			ark.try_place_at_world_pos(world_pos, species)
	
	# 隐藏预览框
	_hide_preview()

func _get_drag_data(_at_position):
	# 开始拖拽时隐藏预览
	_hide_preview()
	return null

func _can_drop_data_fallback(_at_position, _data):
	# 当拖拽离开区域时隐藏预览
	_hide_preview()
	return false

func _hide_preview():
	var ark = get_parent()
	if ark and ark.has_method("hide_preview"):
		ark.hide_preview()
