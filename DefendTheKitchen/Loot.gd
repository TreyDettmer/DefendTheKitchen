extends Area2D
signal collectLoot(lootType, lootValue)

var randRng = RandomNumberGenerator.new()
export var lootValue = 0
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
	match lootType:
		"gold":
			player.setGold(player.getGold() + lootValue)
			
	#emit_signal("collectLoot", lootType, lootValue)
	destroy();

func _init():
	generateLoot()
	
func generateLoot():
	randRng.randomize()
	lootValue = randRng.randi_range(10, 100)
	setLootType("gold") #for now only creates gold loot
	
func setPosition(mapPosition):
	position = mapPosition
