extends Control

func _can_drop_data(at_position, data):
	if data is Dictionary and data.get("type") == "animal_species":
		var species = data.get("species")
		var ark = get_parent()
		if ark:
			# 转换屏幕坐标到世界坐标
			var camera = get_viewport().get_camera_2d()
			var world_pos = camera.get_global_transform().affine_inverse() * at_position
			ark.call("update_placement_preview", world_pos, species)
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
			ark.call("try_place_at_world_pos", world_pos, species)
