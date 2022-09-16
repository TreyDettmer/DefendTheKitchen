extends KinematicBody2D

signal update_inventory
signal update_health

export var speed = 400.0;
var screen_size = Vector2.ZERO;
var direction = Vector2.ZERO;
var aimDirection = Vector2.ZERO;
var healthPoints = 2;
var isDead = false;
var foods = {
	"pizza" : preload("res://Pizza.tscn")
}
var food_count = {
	"pizza" : 0,
	"icecream" : 0
}

func takeDamage(damage):
	if not isDead:
		healthPoints -= damage;
		
		# change player color to communicate hurt
		$AnimatedSprite.modulate = Color(1,0.7,0)
		yield(get_tree().create_timer(0.1),"timeout");
		$AnimatedSprite.modulate = Color(1,1,1)
		print("Player took damage. Health is ", healthPoints);
		# increase size of enemy
		if healthPoints <= 0:
			die();
		
		emit_signal("update_health", healthPoints)
func die():
	if not isDead:
		isDead = true;
		# make all enemies stop 
		hide();
		get_tree().call_group("enemies","disable");
		print("Player died")
		#queue_free();

func _ready():
	screen_size = get_viewport_rect().size;


func _process(_delta):
	if isDead:
		return;
	GetInput();
	
	#Prevents player from clipping into inventory
	position.y = clamp(position.y, 0, 622)
	
	#Keeps inventory positon independent of player movement
	$Inventory.global_position.x = 512
	$Inventory.global_position.y = 715

func GetInput():
	direction = Vector2.ZERO;
	if Input.is_action_pressed("move_right"):
		direction.x += 1;
	if Input.is_action_pressed("move_left"):
		direction.x -= 1;
	if Input.is_action_pressed("move_down"):
		direction.y += 1;
	if Input.is_action_pressed("move_up"):
		direction.y -= 1;
	aimDirection = (get_global_mouse_position() - global_position).normalized();
	if Input.is_action_just_pressed("mouse_click"):
		ThrowFood();
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused;

func _physics_process(_delta):
	if isDead:
		return;
	var _newVelocity = move_and_slide(direction * speed)
	# keep player within screen
	position.x = clamp(position.x,0,screen_size.x);
	position.y = clamp(position.y,0,screen_size.y);

func ThrowFood():
	
	#switch statement with what is equipt currently to switch between things
	
	if food_count["pizza"] > 0:
		var b = foods["pizza"].instance();
		b.direction = aimDirection;
		owner.add_child(b);
		b.global_position = global_position;
		food_count["pizza"] -= 1
		
		emit_signal("update_inventory", food_count)


func update_food(foodStr):
	food_count[foodStr] += 1
	print(food_count[foodStr])
	
	emit_signal("update_inventory", food_count)

func _on_Stove_pizza_added():
	update_food("pizza")


func _on_TitleScreen_nux_mode_on():
	healthPoints = 100000 #essentially unkillable
