extends CanvasLayer


signal level_changed(level_name)

#handling enemy movement
onready var line = $Line2D;

export (String) var level_name = "level"

var level_parameters := {
	"gold": 0
}

#loading old level params into the new level so we don't lose things like health, gold, etc
func load_level_parameters(new_level_parameters: Dictionary):
	level_parameters = new_level_parameters
	$GoldLabel.text = "Gold: " + str(level_parameters.gold)

# Functionality for playing sounds when switching levels
#func play_loaded_sound() -> void:
#	$LevelLoadedSound.play()
#	$ChangeSceneButton.disabled = false

#func cleanup():
#	if $ButtonClickedSound.playing:
#		yield($ButtonClickedSound, "finished")
#	queue_free()


func set_gold(new_gold_amount: int):
	level_parameters.gold = new_gold_amount
	$GoldLabel.text = "Gold: " + str(level_parameters.gold)


#functionality for changing scenes from a button
#make all levels when complete set this off
func _on_ChangeScene() -> void:
	#$ButtonClickedSound.play()
	#$ChangeSceneButton.disabled = true
	#gives 100 gold at the end of each level
	set_gold(level_parameters.gold + 100)
	emit_signal("level_changed", level_name)

func _on_Enemy_pathChanged(path):
	line.points = path;
