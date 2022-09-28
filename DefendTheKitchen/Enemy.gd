extends KinematicBody2D

# This is the "abstract" class that all enemy types inherit from


onready var navigationAgent = $NavigationAgent2D;

signal pathChanged(path);
signal died(_self);

var player = null;
var velocity = Vector2.ZERO;
export (float) var maxSpeed = 70.0;
var origSpeed = 0.0;
var isDead = false;
var canMove = true;
export var canMoveOnAttack = true;
var isAttacking = false;
var canAttack = true;
export (float) var attackCooldown;
export (float) var attackWindup;
export (float) var attackDistance;
export var healthPoints = 1;
export var currentColor = Color(1,1,1);
var isInsideKitchen = false;
#effects from items that impact the enemies
export var statusEffect = {
	"frost" : 50 #lowers speed by 50
}
var normalEnemyPrefab = load("res://Enemy_Normal.tscn");
var bigEnemyPrefab = load("res://Enemy_Big.tscn");
var fastEnemyPrefab = load("res://Enemy_Fast.tscn");
var targettedFood = null;

var randRng = RandomNumberGenerator.new()

# thresholds that determine which navigation polygon (tight, normal, or wide) the enemy should be attached to
var navigationPolygonThresholds = {
	"tight" : 0.5,
	"normal" : 0.7,
	"big" : 1.1
};

func _ready():
	
	player = get_node("../../Player");
	navigationAgent.set_target_location(player.global_position);
	navigationAgent.max_speed = maxSpeed;
	$AnimatedSprite.modulate = currentColor;
	$HealthLabel.text = String(healthPoints);

func _process(delta):
	if isDead:
		return;
	CalculateMovement(delta);

func _test():
	print("test");
	
#This func handles what happens every frame for the enemy
#determines if the enemy is close enough to the player to attack
func _physics_process(_delta):
	if isDead:
		return;
	
	# if we are close enough to player then attack
	if canAttack and (player.global_position - global_position).length_squared() < attackDistance*attackDistance:
		
		# ensure that there is nothing between us and the player
		var space_state = get_world_2d().direct_space_state;
		var raycastResult = space_state.intersect_ray(global_position,player.global_position,[self],0b0001)
		if raycastResult:
			StartAttack();

#This func calculates the movement of the enemies
#Makes them move towards the player if there isn't any food present for them
#to be lured towards
func CalculateMovement(_delta):
	if player != null and canMove:
		# move towards the player
		if (targettedFood != null and is_instance_valid(targettedFood)):
			navigationAgent.set_target_location(targettedFood.global_position);
		else:
			navigationAgent.set_target_location(player.global_position);
		var moveDirection = position.direction_to(navigationAgent.get_next_location());
		velocity = moveDirection * maxSpeed;
		navigationAgent.set_velocity(velocity);

#This function makes the enemy take damage
#modifies the sprite accordingly
func takeDamage(damage):
	if not isDead:
		healthPoints -= damage;
		$HealthLabel.text = String(healthPoints);
		currentColor *= .5
		$AnimatedSprite.modulate = currentColor;	
		if healthPoints <= 0:
			die();

#This function kills the enemy
func die():
	if not isDead:
		isDead = true;
		emit_signal("died",self);
		get_parent().call_deferred("remove_child",self);
		queue_free();

func disable():
	isDead = true;

# signal called by set_velocity() method of navigationAgent
func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	velocity = safe_velocity;
	var _velocity = move_and_slide(velocity);
	for index in get_slide_count():
		var collision := get_slide_collision(index);
		var _body := collision.collider;

# emit information needed to draw enemy's desired path
func _on_NavigationAgent2D_path_changed():
	emit_signal("pathChanged",navigationAgent.get_nav_path());
	
func StartAttack():
	isAttacking = true;
	canAttack = false;
	if not canMoveOnAttack:
		canMove = false;
	$AnimatedSprite.modulate = Color(1,0,0);
	$AttackWindupTimer.start(attackWindup);

func _on_AttackWindupTimer_timeout():
	if (player.global_position - global_position).length_squared() < attackDistance*attackDistance and not isDead:
		player.takeDamage(1.0);
	
	if not canMoveOnAttack:
		canMove = true;
	$AnimatedSprite.modulate = currentColor;
	isAttacking = false;
	$AttackCooldownTimer.start(attackCooldown);


func _on_AttackCooldownTimer_timeout():
	canAttack = true;


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("food") and area.name == "FoodArea2D":
		area.get_parent().HitEnemy(self);
	if (area.name == "KitchenArea2D"):
		isInsideKitchen = true;
		

func activateStatusEffect(effect):
	match effect:
		"frost": #reduce the speed from frost
			origSpeed = maxSpeed #assign temp variable for holding old speed
			maxSpeed -= statusEffect.frost
			$StatusEffectTimer.start()

func _on_StatusEffectTimer_timeout():
	#reset the speed from an effect
	maxSpeed = origSpeed
	
func setFoodLure(food):
	print("Set target!");
	if (targettedFood == null):
		targettedFood = food;


func _on_Area2D_area_exited(area):
	if (area.name == "KitchenArea2D"):
		isInsideKitchen = false;

