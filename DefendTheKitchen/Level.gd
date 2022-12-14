extends CanvasLayer


signal level_changed(level_name)
signal wave_finished
signal start_wave(currentWave)

class Wave:
	var normalEnemyCount: int;
	var fastEnemyCount: int;
	var bigEnemyCount: int;
	var bossEnemyCount: int;
	
	
	func _init(_normalEnemyCount:int = 1, _fastEnemyCount:int = 0, _bigEnemyCount:int = 0, _bossEnemyCount:int = 0):
		normalEnemyCount = _normalEnemyCount;
		fastEnemyCount = _fastEnemyCount;
		bigEnemyCount = _bigEnemyCount;
		bossEnemyCount = _bossEnemyCount;

var currentWave = 1;

var moneyBagLoot = preload("res://Loot.tscn");
var normalEnemyPrefab = preload("res://Enemy_Normal.tscn");
var fastEnemyPrefab = preload("res://Enemy_Fast.tscn");
var bigEnemyPrefab = preload("res://Enemy_Big.tscn");
var bossEnemyPrefab = preload("res://Enemy_Boss.tscn");
var possibleSpawnPoints = [];
export var canThrowFoodOutsideKitchen = false;
var waves = [Wave.new(3,0,0), Wave.new(3,2,0),Wave.new(5,3,1), Wave.new(5,2,2), Wave.new(6,3,2),Wave.new(7,4,2),Wave.new(5,4,2,1)]
var rng = RandomNumberGenerator.new()
var aliveEnemies = 0;
var waveGold = 15
var enemySoundPlayed = false

var isBetweenWaves = false;

export (String) var level_name = "level"

var level_parameters := {
	"gold": 0,
	"nuxMode" : false
}

#loading old level params into the new level so we don't lose things like health, gold, etc
func load_level_parameters(new_level_parameters: Dictionary):
	level_parameters = new_level_parameters
	$Player.nuxMode(level_parameters.nuxMode)
	
	start_level();
	
func start_level():
	rng.randomize();
	possibleSpawnPoints = $EnemySpawnPoints.get_children();
	spawn_wave();

func set_gold(new_gold_amount: int):
	level_parameters.gold = new_gold_amount
	#$GoldLabel.text = "Gold: " + str(level_parameters.gold)

#functionality for changing scenes from a button
#make all levels when complete set this off
func _on_ChangeScene() -> void:
	emit_signal("level_changed", level_name)
	
#This func spawns all the waves for the game
#Runs through the arrays of different types of enemies for that wave
#and spawns them in pseudorandomly
func spawn_wave():
	global.waveNum+= 1 #for score calc
	# get the current wave
	var wave = waves[currentWave - 1];
	# random starting spawn point
	var spawnPointIndex = rng.randi_range(0,possibleSpawnPoints.size());
	# spawn the base enemies
	for _n in range(wave.normalEnemyCount):
		var enemy = normalEnemyPrefab.instance();
		
		enemy.position = possibleSpawnPoints[spawnPointIndex % possibleSpawnPoints.size()].position;
		
		# connect enemy death signal so we can update enemy count
		enemy.connect("died",self,"enemy_died");
		$Navigation2D_Normal.call_deferred("add_child",enemy);
		aliveEnemies += 1;
		spawnPointIndex += 1;
		# slight delay between enemy spawns
		yield(get_tree().create_timer(0.5),"timeout");
		
	# spawn the fast enemies
	for _n in range(wave.fastEnemyCount):
		var enemy = fastEnemyPrefab.instance();
		
		
		enemy.position = possibleSpawnPoints[spawnPointIndex % possibleSpawnPoints.size()].position;
		
		# connect enemy death signal so we can update enemy count
		enemy.connect("died",self,"enemy_died");
		$Navigation2D_Normal.call_deferred("add_child",enemy);
		aliveEnemies += 1;
		spawnPointIndex += 1;
		
		# slight delay between enemy spawns
		yield(get_tree().create_timer(0.5),"timeout");
	
	
	# spawn the big enemies
	for _n in range(wave.bigEnemyCount):
		var enemy = bigEnemyPrefab.instance();
		
		enemy.position = possibleSpawnPoints[spawnPointIndex % possibleSpawnPoints.size()].position;
		
		# connect enemy death signal so we can update enemy count
		enemy.connect("died",self,"enemy_died");
		$Navigation2D_Wide.call_deferred("add_child",enemy);
		aliveEnemies += 1;
		spawnPointIndex += 1;
		
		# slight delay between enemy spawns
		yield(get_tree().create_timer(0.5),"timeout");
		
	# spawn the boss enemies
	for _n in range(wave.bossEnemyCount):
		print("Spawning boss enemy");
		var enemy = bossEnemyPrefab.instance();
		
		enemy.position = possibleSpawnPoints[spawnPointIndex % possibleSpawnPoints.size()].position;
		
		# connect enemy death signal so we can update enemy count
		enemy.connect("died",self,"enemy_died");
		$Navigation2D_Wide.call_deferred("add_child",enemy);
		aliveEnemies += 1;
		spawnPointIndex += 1;
		
		# slight delay between enemy spawns
		yield(get_tree().create_timer(0.5),"timeout");

func enemy_died(_enemy):
	if !_enemy.isInsideKitchen:
		spawnLoot(_enemy)
	aliveEnemies -= 1;
	print("Enemy Died!!!");
	if aliveEnemies <= 0:
		complete_wave();
		
func distributeBossMinions(_boss):
	if !is_instance_valid(_boss):
		return;
	for i in _boss.numberOfMinions:
		var enemy = fastEnemyPrefab.instance();
		if !is_instance_valid(_boss):
			return;
		enemy.position = _boss.position;
		
		# connect enemy death signal so we can update enemy count
		enemy.connect("died",self,"enemy_died");
		$Navigation2D_Normal.call_deferred("add_child",enemy);
		aliveEnemies += 1;
		
		# slight delay between enemy spawns
		yield(get_tree().create_timer(0.5),"timeout");
		
func complete_wave():
	print("Completed wave");
	isBetweenWaves = true;
	$Player.setGold($Player.getGold() + waveGold) #Adding reward gold to players inventory
	print("Added " + str(waveGold) + " Gold")
	$Player.canThrowFood = false;
	
	if currentWave >= waves.size():
		print("You won!");
		global.gameOverWin = true
		global.setScore()
		get_tree().change_scene("res://Main.tscn") #restart the game from main menu
	else:	
		#start the timer for waiting inbetween waves
		emit_signal("wave_finished")

#received from the button pressed by the player to go to the next wave
func _on_HUD_nextWave():
	currentWave += 1;
	emit_signal("start_wave", currentWave)
	isBetweenWaves = false;
	spawn_wave();
	$Player.canThrowFood = true;


func _on_KitchenArea2D_body_entered(body):
	if body.name == "Player" and !canThrowFoodOutsideKitchen:
		$Player.canThrowFood = true;


func _on_KitchenArea2D_body_exited(body):
	if body.name == "Player" and !canThrowFoodOutsideKitchen:
		$Player.canThrowFood = false;
		
func spawnLoot(_enemy):
	var loot = moneyBagLoot.instance()
	loot.setPosition(_enemy.position)
	call_deferred("add_child",loot) #create a loot child on the node


func _on_EnemyDeathSound_finished():
	$EnemyDeathSound.stop()
	enemySoundPlayed = true
