extends Node
#this script has global variables, for now just the score and nux mode

var score = 0
var nuxMode = false
var gameOver = false
var gameOverWin = false
var waveNum = 0
var gold = 0

#simple score creation based on waves reached and gold obtained
func setScore():
	score = gold*waveNum

func resetVars():
	gameOver = false
	gameOverWin = false
	score = 0
	waveNum = 0
	gold = 0
