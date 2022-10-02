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
	if global.gameOver: #lose case
		$GameTitle.hide()
		$GameOver.show()
		$GameOverWin.hide()
		$StartButton.text = "Restart"
		$Score.text = "Score: " + str(global.score) 
	elif global.gameOverWin: #win case, player beat all levels
		$GameTitle.hide()
		$GameOver.hide()
		$GameOverWin.show()
		$StartButton.text = "Restart"
		$Score.text = "Score: " + str(global.score) 
	else: #default first case
		$GameTitle.show()
		$GameOver.hide()
		$GameOverWin.hide()
		$StartButton.text = "Start" 
		$Score.hide()

func _on_StartButton_pressed():
	$InteractSoundShort.play()
	yield(get_tree().create_timer(0.5), "timeout")
	#$TitleScreenMusic.stop()
	global.resetVars()
	emit_signal("level_changed", level_num)

#function to tell the main game if nux mode should be on or off
func _on_ToggleNuxMode_toggled(button_pressed):
	$InteractSoundShort.play()
	emit_signal("nux_mode", button_pressed)

func set_nuxMode(nux: bool):
	level_parameters.nuxMode = nux
	global.nuxMode = nux

func _on_QuitButton_pressed():
	$InteractSoundShort.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()


func _on_ControlsButton_pressed():
	emit_signal("showControls",true) #tell parent to pause game
	$ControlsScreen.show()

func _on_ControlsScreen_CloseControls():
	$ControlsScreen.hide()
	emit_signal("showControls", false) #tell parent to play the game
