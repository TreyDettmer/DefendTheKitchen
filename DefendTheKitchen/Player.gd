extends KinematicBody2D

signal update_inventory;
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

var foods = {
	"pizza" : preload("res://Pizza.tscn"),
	"icecream" : preload("res://Icecream.tscn")
}
var food_count = {
	"pizza" : 1,
	"icecream" : 0
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
	if levelNode.isBetweenWaves:
		$AnimatedSprite.play("default");
		return;
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
		ThrowFood();
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused;
	if Input.is_action_just_pressed("Equip1"):
		currentEquip = 1; #pizza
	if Input.is_action_just_pressed("Equip2"):
		currentEquip = 2; #icecream
	#if Input.is_action_just_pressed("pause"):

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
				
				emit_signal("update_inventory", food_count)
		2:
			if food_count["icecream"] > 0:
				var b = foods["icecream"].instance();
				b.direction = aimDirection;
				owner.add_child(b);
				# spawn food in front of player
				b.global_position = global_position + aimDirection * 30.0;
				food_count["icecream"] -= 1
				
				emit_signal("update_inventory", food_count)


func update_food(foodStr):
	food_count[foodStr] += 1
	print("You have " + str(food_count[foodStr]) + " " + foodStr)
	
	emit_signal("update_inventory", food_count)


#turns on nux mode for testing, makes the player ESSENTIALLY unkillable
func nuxMode(nuxToggle: bool):
	if nuxToggle:
		healthPoints = 1000000 #essentially unkillable

#returns the player's current gold amount
func getGold():
	return gold

#sets the player's gold
func setGold(incomingGold):
	gold = incomingGold
	emit_signal("update_gold", gold)

func _on_Stove_pizza_added():
	update_food("pizza")

func _on_IcecreamMachine_icecream_added():
	update_food("icecream")
	

#controls interactions between the player and loot
func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("loot") and area.name == "LootArea2D":
		area.get_parent().HitPlayer(self);
