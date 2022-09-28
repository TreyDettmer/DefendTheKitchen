extends KinematicBody2D

signal update_inventory(_food_count,_currentEquip);
signal update_health;
signal update_gold(gold);

export var speed = 400.0;
var screen_size = Vector2.ZERO;
var direction = Vector2.ZERO;
var aimDirection = Vector2.ZERO;
export var healthPoints = 2;
var isDead = false;
export var gold = 0;
var currentEquip = 1;
var levelNode;
var canThrowFood = true;
var mouseClickEnabled = true;

# Stuff for the upgrade buttons that appear over appliances
const upgradeButtonResource = preload("res://UpgradeButton.tscn");
var loadedUpgradeButtons = {};

var foods = {
	"pizza" : preload("res://Pizza.tscn"),
	"icecream" : preload("res://Icecream.tscn"),
	"rice" : preload("res://Rice.tscn")
}
var food_count = {
	"pizza" : 0,
	"icecream" : 0,
	"rice" : 0,
}

func takeDamage(damage):
	if not isDead:
		healthPoints -= damage;
		
		# change player color to communicate hurt
		$AnimatedSprite.modulate = Color(1,0.7,0)
		yield(get_tree().create_timer(0.1),"timeout");
		$AnimatedSprite.modulate = Color(1,1,1)
		print("Player took damage. Health is ", healthPoints);
		# increase size of enemy
		if healthPoints <= 0:
			die();
		
		emit_signal("update_health", healthPoints)
func die():
	if not isDead:
		isDead = true;
		# make all enemies stop 
		hide();
		get_tree().call_group("enemies","disable");
		print("Player died")
		#Change to game over scene
		global.setScore()
		global.gameOver = true
		get_tree().change_scene("res://Main.tscn")
		#queue_free();

func _ready():
	screen_size = get_viewport_rect().size;
	levelNode = get_parent();


func _process(_delta):
	if isDead:
		return;
	GetInput();

func GetInput():
	direction = Vector2.ZERO;
	if Input.is_action_pressed("move_right"):
		direction.x += 1;
		$AnimatedSprite.play("walk");
	if Input.is_action_pressed("move_left"):
		direction.x -= 1;
		$AnimatedSprite.play("walk");
	if Input.is_action_pressed("move_down"):
		direction.y += 1;
		$AnimatedSprite.play("walk");
	if Input.is_action_pressed("move_up"):
		direction.y -= 1;
		$AnimatedSprite.play("walk");
	# I'm sorry, I know this sucks :(
	if (!Input.is_action_pressed("move_up") and !Input.is_action_pressed("move_down")
	and !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right")):
		$AnimatedSprite.play("default");
	aimDirection = (get_global_mouse_position() - global_position).normalized();
	$AnimatedSprite.rotation = aimDirection.angle() + 90;
	
	if Input.is_action_just_pressed("mouse_click"):
		
		# mouseClickEnabled is set to false when the player clicks the
		# upgrade button (see UpgradeButton.gd). This prevents the player from 
		# shooting food when interacting with gui elements.
		if mouseClickEnabled:
			ThrowFood();
		else:
			mouseClickEnabled = true;
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused;
	if Input.is_action_just_pressed("Equip1"):
		if food_count.values()[0] != 0:
			currentEquip = 1; #pizza
			emit_signal("update_inventory", food_count,currentEquip)
	if Input.is_action_just_pressed("Equip2"):
		if food_count.values()[1] != 0:
			currentEquip = 2; #icecream
			emit_signal("update_inventory", food_count,currentEquip)
	if Input.is_action_just_pressed("Equip3"):
		if food_count.values()[2] != 0:
			currentEquip = 3; #rice
			emit_signal("update_inventory", food_count,currentEquip)
	
	
func hasFood():
	for value in food_count.values():
		if value != 0:
			return true;
	return false;

func _physics_process(_delta):
	if isDead:
		return;
	var _newVelocity = move_and_slide(direction * speed)
	# keep player within screen
	position.x = clamp(position.x,0,screen_size.x);
	position.y = clamp(position.y,0,screen_size.y);

func ThrowFood():
	if !canThrowFood:
		return;
	
	#match statement with what is equipted currently to switch between things
	match currentEquip:
		1: #pizza case
			if food_count["pizza"] > 0:
				var b = foods["pizza"].instance();
				b.direction = aimDirection;
				owner.add_child(b);
				# spawn food in front of player
				b.global_position = global_position + aimDirection * 30.0;
				food_count["pizza"] -= 1
				
				emit_signal("update_inventory", food_count,currentEquip)
		2:
			if food_count["icecream"] > 0:
				var b = foods["icecream"].instance();
				b.direction = aimDirection;
				owner.add_child(b);
				# spawn food in front of player
				b.global_position = global_position + aimDirection * 30.0;
				food_count["icecream"] -= 1
				
				emit_signal("update_inventory", food_count,currentEquip)
		3:
			if food_count["rice"] > 0:
				var b = foods["rice"].instance();
				b.direction = aimDirection;
				owner.add_child(b);
				# spawn food in front of player
				b.global_position = global_position + aimDirection * 30.0;
				food_count["rice"] -= 1
				
				emit_signal("update_inventory", food_count,currentEquip)


func update_food(foodStr, amount = 1):
	if !hasFood():
		currentEquip = food_count.keys().find(foodStr) + 1;
		print("Current equip set to " + String(currentEquip))
	food_count[foodStr] += amount;
	print("You have " + str(food_count[foodStr]) + " " + foodStr)
	
	emit_signal("update_inventory", food_count,currentEquip)


#turns on nux mode for testing, makes the player ESSENTIALLY unkillable
func nuxMode(nuxToggle: bool):
	if nuxToggle:
		healthPoints = 1000000 # unkillable almost

#returns the player's current gold amount
func getGold():
	return gold

#sets the player's gold
func setGold(incomingGold):
	gold = incomingGold
	global.gold += incomingGold #keeps track of gold obtained throughout time
	emit_signal("update_gold", gold)

func _on_Stove_pizza_added():
	update_food("pizza")

func _on_IcecreamMachine_icecream_added():
	update_food("icecream")
	

#controls interactions between the player and loot
func _on_ApplianceDetectionArea_area_entered(area):
	if area.get_parent().is_in_group("loot") and area.name == "LootArea2D":
		area.get_parent().HitPlayer(self);


func _on_RiceCooker_rice_added():
	update_food("rice",5);


func _on_ApplianceDetectionArea_body_entered(body):
	var body_groups = body.get_groups();
	
	# Create a new UpgradeButton instance and attach it to the appliance
	if body_groups.has("appliances"):
		
		var upgradeButton = upgradeButtonResource.instance();
		var button = upgradeButton.get_node("Button");
		var text = upgradeButton.get_node("RichTextLabel");
		get_parent().add_child(upgradeButton);
		
		upgradeButton.global_position = body.global_position;
		upgradeButton.player = self;
		upgradeButton.appliance = body;
		
		upgradeButton.connect("playerPressedUpgrade", body, "_upgrade");
		body.connect("update_upgrade", upgradeButton, "updateButtonText");
		
		upgradeButton.updateButtonText(body.upgradeCost);
		
		# Add this upgrade button to the list so it can be unloaded
		# once the player leaves the area
		loadedUpgradeButtons[body] = upgradeButton;
		
		


# Handles unloading of upgrade buttons from appliances
func _on_ApplianceDetectionArea_body_exited(body):
	
	if loadedUpgradeButtons.has(body):
		loadedUpgradeButtons[body].queue_free();
