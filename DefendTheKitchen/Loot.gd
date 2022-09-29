extends Area2D
signal collectLoot(lootType, lootValue)

var randRng = RandomNumberGenerator.new()
export var lootValue = 0
var collected = false
export var lootType = { 
		"gold" : false,
		"speed" : false,
		"item" : false
	}

func start():
	pass
	
func destroy():
	queue_free();

func setLootValue(value):
	lootValue = value

func setLootType(type):
	match type:
		"gold":
			lootType["gold"] = true
		"speed":
			lootType["speed"] = true
		"item":
			lootType["item"] = true

func HitPlayer(player):
	if !collected:
		if lootType["gold"]:
			player.setGold(player.getGold() + lootValue)
			collected = true
			hide()
			$LootSound.play()

func _init():
	generateLoot()
	
func generateLoot():
	lootValue = 5
	setLootType("gold") #for now only creates gold loot
	
func setPosition(mapPosition):
	position = mapPosition


func _on_LootSound_finished():
	destroy()
