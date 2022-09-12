extends Node2D

func _on_Player_update_inventory(food_count):
	$PizzaLabel.text = str(food_count["pizza"])
	


func _on_Player_update_health(health):
	match int(health):
		0:
			$HealthBar.texture = load("res://Art/health_none.png")
		1:
			$HealthBar.texture = load("res://Art/health_half.png")
		2:
			$HealthBar.texture = load("res://Art/health_sprite.png")
