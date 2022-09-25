extends Node2D

var currentEquip = 0;
func _ready():
	get_parent().get_parent().get_node("Player").connect("update_gold",self, "_on_Player_update_gold")
	get_parent().get_parent().get_node("Player").connect("update_health",self, "_on_Player_update_health")
	get_parent().get_parent().get_node("Player").connect("update_inventory",self, "_on_Player_update_inventory")

func _on_Player_update_inventory(food_count,_currentEquip):
	if $PizzaLabel.text < str(food_count["pizza"]):
		highlight_icon($PizzaIcon);
	if $IcecreamLabel.text < str(food_count["icecream"]):
		highlight_icon($IcecreamIcon);
	$PizzaLabel.text = str(food_count["pizza"])
	$IcecreamLabel.text = str(food_count["icecream"])
	if currentEquip != _currentEquip:
		currentEquip = _currentEquip;
		if currentEquip == 1:
			switched_currentEquip($PizzaIcon)
		elif currentEquip == 2:
			switched_currentEquip($IcecreamIcon)

func _on_Player_update_gold(gold_count):
	$GoldLabel.text = str(gold_count)

func _on_Player_update_health(health):
	match int(health):
		0:
			$HealthBar.texture = load("res://Art/health_none.png")
		1:
			$HealthBar.texture = load("res://Art/health_half.png")
		2:
			$HealthBar.texture = load("res://Art/health_sprite.png")
			
func switched_currentEquip(icon):
	$EquipHighlight.text = "_";
	if icon == $PizzaIcon:
		$EquipHighlight.rect_global_position = $PizzaIcon.global_position - Vector2(35,0);
	elif icon == $IcecreamIcon:
		$EquipHighlight.rect_global_position = $IcecreamIcon.global_position - Vector2(35,0)
			
func highlight_icon(icon):
	for i in 3:
		icon.scale += Vector2(0.3,0.3);
		yield(get_tree().create_timer(0.05),"timeout")
	for i in 3:
		icon.scale -= Vector2(0.3,0.3);
		yield(get_tree().create_timer(0.05),"timeout")

