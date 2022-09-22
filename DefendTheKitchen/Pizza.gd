extends "res://Food.gd"

var health = 8;
var maxLure = 4;
var luredMobs = [];

func _process(delta):
	rotation += rotationSpeed * delta;

func _physics_process(_delta):
	var _velocity = move_and_slide(direction * speed);
	if (speed > 40):
		speed *= (59.2*_delta);
	else:
		speed = 0;
		
func HitEnemy(enemy):
	enemy.takeDamage(1.0);
	health -= 1;
	$AnimatedSprite.frame = (8 - health);
	
	if (health <= 0):
		destroy();


func _on_MobLure_body_entered(body):
	if ((body.is_in_group("enemies") or body.get_parent().get_filename() == "res://Enemy.tscn")
		and maxLure > 0):
			
		body.setFoodLure(self);
		maxLure -= 1;
		luredMobs.push_back(body);
		
		$MobLureTimer.start();
		
		
# This function is used to cause a mob to repeatedly tick damage when inside
# the range of the pizza
func _on_MobLureTimer_timeout():
	
	var timerFlag = false;
	for mob in luredMobs:
		if mob != null and is_instance_valid(mob):
			HitEnemy(mob);
			timerFlag = true;
	
	if timerFlag:
		$MobLureTimer.start();
