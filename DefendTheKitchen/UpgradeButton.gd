extends Node2D

var player = null;
var appliance = null;

signal playerPressedUpgrade;

# Replaces the button text with the new integer val
func updateButtonText(val):
	
	$RichTextLabel.text = "";
	$RichTextLabel.push_color(Color.white);
	$RichTextLabel.add_text("Upgrade: ");
	
	if (val > player.gold):
		$RichTextLabel.push_color(Color.red);
	else:
		$RichTextLabel.push_color(Color.green);
		
	$RichTextLabel.add_text("($" + str(val) + ")");

# Verifies whether or not the player's request to upgrade an appliance
# was valid and emits a signal if it was
func _on_Button_pressed():
	
	player.mouseClickEnabled = false;
	
	if (player.gold >= appliance.upgradeCost):
		
		emit_signal("playerPressedUpgrade");
		player.setGold(player.gold - appliance.upgradeCost);
		updateButtonText(appliance.upgradeCost);
