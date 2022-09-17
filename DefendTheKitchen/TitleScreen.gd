extends Node2D

signal nux_mode(button_pressed)
signal level_changed(level_name)

export (int) var level_num = 0

var level_parameters := {
	"gold": 0,
	"nuxMode" : false
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_StartButton_pressed():
	yield(get_tree().create_timer(1), "timeout")
	#get_tree().change_scene("res://Main.tscn")
	emit_signal("level_changed", level_num)
	#$TitleScreen.hide()

#function to tell the main game if nux mode should be on or off
func _on_ToggleNuxMode_toggled(button_pressed):
	emit_signal("nux_mode", button_pressed)

func set_nuxMode(nux: bool):
	level_parameters.nuxMode = nux
