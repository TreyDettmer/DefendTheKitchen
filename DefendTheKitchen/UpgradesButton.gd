extends MenuButton


var _last_mouse_position

#onready var _menu = $UpgradesButton

#func _input(event):
#	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
#		_last_mouse_position = get_global_mouse_position()
#		_menu.popup(Rect2(_last_mouse_position.x, _last_mouse_position.y, _menu.rect_size.x, _menu.rect_size.y))
