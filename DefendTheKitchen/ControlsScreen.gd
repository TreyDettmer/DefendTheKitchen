extends Node2D

signal CloseControls

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_CloseButton_pressed():
	emit_signal("CloseControls")
