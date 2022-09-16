extends Node2D

signal start_game
signal nux_mode_on
signal nux_mode_off
signal level_changed(level_name)

export (int) var level_num = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_StartButton_pressed():
	emit_signal("start_game")
	yield(get_tree().create_timer(1), "timeout")
	#get_tree().change_scene("res://Main.tscn")
	emit_signal("level_changed", level_num)
	#$TitleScreen.hide()

#function to tell the main game if nux mode should be on or off
func _on_ToggleNuxMode_toggled(button_pressed):
	if button_pressed:
		emit_signal("nux_mode_on")
	else:
		emit_signal("nux_mode_off")
