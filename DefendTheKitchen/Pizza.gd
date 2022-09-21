extends "res://Food.gd"

var health = 8;
var maxLure = 4;

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
	if (body.is_in_group("enemies") or body.get_parent().get_filename() == "res://Enemy.tscn"):
		body.setFoodLure(self);
