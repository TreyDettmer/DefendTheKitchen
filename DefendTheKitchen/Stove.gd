extends StaticBody2D

export(PackedScene) var object_scene: PackedScene = null

var is_player_inside: bool = false
var is_cooking: bool = false
var done_cooking = false
signal pizza_added
signal update_upgrade;

export var upgradeCost = 10;

# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.visible = false;
	$FoodSprite.visible = false;
	
	add_to_group("appliances");

func _input(event: InputEvent):
	# don't allow interaction during downtime
	if get_parent().isBetweenWaves:
		return;
	#start cooking food
	if event.is_action_pressed("interact") and is_player_inside and not is_cooking:
		$StoveTimer.start()
		is_cooking = true
		done_cooking = false
		$ProgressBar.visible = true;
		print("Food is cooking!")
	#pick up cooked food
	if event.is_action_pressed("interact") and is_player_inside and done_cooking:
		drop_pizza() #add a pizza to the player's inventory
		is_cooking = false
		print("You have received your food!")
		
	
func _process(delta):
	if !$StoveTimer.is_stopped():
		if $StoveTimer.get_time_left() > 0:
			var percent = ((1 - $StoveTimer.get_time_left() / $StoveTimer.get_wait_time()) * 100);
			$ProgressBar.value = int(percent);

func _on_StoveTimer_timeout():
	done_cooking = true
	$ProgressBar.visible = false;
	$FoodSprite.visible = true;
	print("Done cooking!");

#drop the pizza into the player's inventory
func drop_pizza():
	$FoodSprite.visible = false;
	emit_signal("pizza_added")
	

func _on_Area2D_body_entered(_body):
	if _body.is_in_group("players"):
		is_player_inside = true


func _on_Area2D_body_exited(_body):
	if _body.is_in_group("players"):
		is_player_inside = false
	
# Called whenever the player presses the "Upgrade" button on the appliance.
# This function is dynamically connected to the pressed() signal on the button	
func _upgrade():
	self.upgradeCost += 10;
	emit_signal("update_upgrade", upgradeCost);
	
	# TODO This is just an upgrade example
	$StoveTimer.wait_time = 1;
