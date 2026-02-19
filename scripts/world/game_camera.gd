extends Camera2D

@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.05

var _is_dragging: bool = false

func _input(event):
	# 1. 缩放逻辑
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-zoom_speed)
		
		# 2. 平移开启判断
		if event.button_index == MOUSE_BUTTON_LEFT:
			# 如果点击发生在底部 UI 区 (y > 600)，或者正在进行拖拽，则禁止平移
			var is_on_ui = event.position.y > 600
			
			# 修正：使用 Godot 4 标准函数 gui_is_dragging()
			var is_dragging_item = get_viewport().gui_is_dragging()
			
			if event.pressed:
				if not is_on_ui and not is_dragging_item:
					_is_dragging = true
				else:
					_is_dragging = false
			else:
				_is_dragging = false

	# 3. 执行平移
	if event is InputEventMouseMotion and _is_dragging:
		# 再次检查，防止拖拽过程中意外开启平移
		if get_viewport().gui_is_dragging():
			_is_dragging = false
			return
			
		position -= event.relative / zoom

	# 4. 移动端触控平移适配
	if event is InputEventScreenDrag:
		# 如果手指在 UI 区域或者正在拖拽，不平移地图
		if event.position.y < 600 and not get_viewport().gui_is_dragging():
			position -= event.relative / zoom

func _apply_zoom(delta):
	var new_zoom = clamp(zoom.x + delta, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)

func _process(_delta):
	# 限制平移范围
	position.x = clamp(position.x, 0, 1280)
	position.y = clamp(position.y, 0, 720)