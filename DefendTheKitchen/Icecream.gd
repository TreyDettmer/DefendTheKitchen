extends "res://Food.gd"

func _process(delta):
	rotation += rotationSpeed * delta;

func _physics_process(_delta):
	var _velocity = move_and_slide(direction * speed);
	for index in get_slide_count():
		var collision := get_slide_collision(index);
		var body := collision.collider;
		if body.is_in_group("enemies"):
			HitEnemy(body);
		destroy();
		break;


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("enemies"):
		HitEnemy(area.get_parent());
	destroy();
	

func HitEnemy(enemy):
	#enemy.statusEffect("frost")
	enemy.takeDamage(1.0);
	destroy();
