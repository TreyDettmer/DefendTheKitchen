extends "res://Enemy.gd"

var hasDistributedMinions = false;

var enemy_Fast = preload("res://Enemy_Fast.tscn");
export var numberOfMinions = 4;

#This function makes the enemy take damage
#modifies the sprite accordingly
func takeDamage(damage):
	.takeDamage(damage);
	if not isDead:
		if healthPoints <= 2.0 and !hasDistributedMinions:
			distributeMinions();

func distributeMinions():
	hasDistributedMinions = true;
	get_parent().get_parent().distributeBossMinions(self);

