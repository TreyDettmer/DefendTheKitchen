extends CanvasLayer


signal level_changed(level_name)
signal wave_finished
signal start_wave(currentWave)

class Wave:
	var normalEnemyCount: int;
	var fastEnemyCount: int;
	var bigEnemyCount: int;
	
	
	func _init(_normalEnemyCount:int = 1, _fastEnemyCount:int = 0, _bigEnemyCount:int = 0):
		normalEnemyCount = _normalEnemyCount;
		fastEnemyCount = _fastEnemyCount;
		bigEnemyCount = _bigEnemyCount;

var currentWave = 1;

var normalEnemyPrefab = preload("res://Enemy_Normal.tscn");
var fastEnemyPrefab = preload("res://Enemy_Fast.tscn");
var bigEnemyPrefab = preload("res://Enemy_Big.tscn");
var possibleSpawnPoints = [];

var waves = [Wave.new(1,1,1), Wave.new(4,1,1)]
var rng = RandomNumberGenerator.new()
var aliveEnemies = 0;
export var waveGold = 100;

export (String) var level_name = "level"

var level_parameters := {
	"gold": 0,
	"nuxMode" : false
}

#loading old level params into the new level so we don't lose things like health, gold, etc
func load_level_parameters(new_level_parameters: Dictionary):
	level_parameters = new_level_parameters
	$Player.nuxMode(level_parameters.nuxMode)
	#$GoldLabel.text = "Gold: " + str(level_parameters.gold)
	
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
	#gives 100 gold at the end of each level
	set_gold(level_parameters.gold + 100)
	emit_signal("level_changed", level_name)
	
	
func spawn_wave():
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

func enemy_died(_enemy):
	aliveEnemies -= 1;
	print("Enemy Died!!!");
	if aliveEnemies <= 0:
		complete_wave();
		
func complete_wave():
	print("Completed wave");
	
	$Player.setGold($Player.getGold() + waveGold) #Adding reward gold to players inventory
	print("Added " + str(waveGold) + " Gold")
	
	if currentWave - 1 > waves.size():
		print("You won!");
	else:	
		#start the timer for waiting inbetween waves
		emit_signal("wave_finished")

#received from the button pressed by the player to go to the next wave
func _on_HUD_nextWave():
	currentWave += 1;
	emit_signal("start_wave", currentWave)
	spawn_wave();
