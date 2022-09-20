extends Control

signal nextWave

# Called when the node enters the scene tree for the first time.
func _ready():
	$NextWaveButton.hide()
	pass # Replace with function body.

func setWaveNumber(waveNum):
	$WaveNumber.text = "Wave: " + str(waveNum)

func _on_NextWaveButton_pressed():
	emit_signal("nextWave")
	$NextWaveButton.hide()

#run commands for finishing a wave
func _on_Level1_wave_finished():
	$NextWaveButton.show() #make the next wave button available

#run commands for a new wave coming in
func _on_Level1_start_wave(currentWave):
	setWaveNumber(currentWave)
