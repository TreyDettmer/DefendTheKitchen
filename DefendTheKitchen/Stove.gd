extends StaticBody2D

export(PackedScene) var object_scene: PackedScene = null

var is_player_inside: bool = false
var is_cooking: bool = false
var done_cooking = false
signal pizza_added

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event: InputEvent):
	#start cooking food
	if event.is_action_pressed("interact") and is_player_inside and not is_cooking:
		$StoveTimer.start()
		is_cooking = true
		done_cooking = false
		$AnimatedSprite.modulate = Color(1,0.7,0)
		print("Food is cooking!")
	#pick up cooked food
	if event.is_action_pressed("interact") and is_player_inside and done_cooking:
		drop_pizza() #add a pizza to the player's inventory
		is_cooking = false
		$AnimatedSprite.modulate = Color(1,1,1)
		print("You have received your food!")
		
	

func _on_StoveTimer_timeout():
	done_cooking = true
	$AnimatedSprite.modulate = Color(0,1.0,0)
	print("Done cooking!");

#drop the pizza into the player's inventory
func drop_pizza():
	emit_signal("pizza_added")
	

func _on_Area2D_body_entered(_body):
	is_player_inside = true


func _on_Area2D_body_exited(_body):
	is_player_inside = false
