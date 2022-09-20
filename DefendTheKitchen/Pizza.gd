extends "res://Food.gd"

func _process(delta):
	rotation += rotationSpeed * delta;

func _physics_process(_delta):
	var _velocity = move_and_slide(direction * speed);
	for index in get_slide_count():
		var collision := get_slide_collision(index);
		var body := collision.collider;
		destroy();
		break;
	

func HitEnemy(enemy):
	enemy.takeDamage(1.0);
	destroy();
