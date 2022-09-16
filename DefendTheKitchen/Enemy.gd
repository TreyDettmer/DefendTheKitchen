extends KinematicBody2D

onready var navigationAgent = $NavigationAgent2D;

signal pathChanged(path);

export (NodePath) var playerNodePath;
var player = null;
var velocity = Vector2.ZERO;
export var maxSpeed = 1.0;
# since we aren't currently changing the sprite to make the enemy look fatter, we just change the size of the sprite
export var damageSpriteScaleFactor = 1.25;
var isDead = false;
var canMove = true;
export var canMoveOnAttack = true;
var isAttacking = false;
var canAttack = true;
export var attackCooldown = 1.0;
export var attackWindup = 1.0;
export var attackDistance = 200;
export var healthPoints = 3;
var currentColor = Color(1,1,1);

func _ready():
	if player != null:
		player = get_node(playerNodePath);
		navigationAgent.set_target_location(player.global_position);
		navigationAgent.max_speed = maxSpeed;
		$AnimatedSprite.modulate = currentColor;

func _process(delta):
	if isDead:
		return;
	CalculateMovement(delta);

		
func _physics_process(_delta):
	if player != null:
		if isDead:
			return;
	
		# if we are close enough to player then attack
		if canAttack and (player.global_position - global_position).length_squared() < attackDistance*attackDistance:
			
			# ensure that there is nothing between us and the player
			var space_state = get_world_2d().direct_space_state;
			var raycastResult = space_state.intersect_ray(global_position,player.global_position,[self],0b0001)
			if raycastResult:
			
				attackPlayer();
		

func CalculateMovement(_delta):
	if player != null and canMove:
		# move towards the player
		navigationAgent.set_target_location(player.global_position);
		var moveDirection = position.direction_to(navigationAgent.get_next_location());
		velocity = moveDirection * maxSpeed;
		navigationAgent.set_velocity(velocity);
		
		
		
func takeDamage(damage):
	if not isDead:
		healthPoints -= damage;
		currentColor *= .5
		$AnimatedSprite.modulate = currentColor;
		
		# increase size of enemy
		# not doing this right now because of collision issues
		#$AnimatedSprite.scale *= damageSpriteScaleFactor;
		#$CollisionShape2D.shape.radius *= damageSpriteScaleFactor;
		if healthPoints <= 0:
			die();
func die():
	if not isDead:
		isDead = true;
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


func attackPlayer():
	if player != null:
		isAttacking = true;
		canAttack = false;
		print("starting attack...")
		if not canMoveOnAttack:
			canMove = false;
		$AnimatedSprite.modulate = Color(1,0,0);
		yield(get_tree().create_timer(attackWindup),"timeout");
		if (player.global_position - global_position).length_squared() < attackDistance*attackDistance and not isDead:
			player.takeDamage(1.0)
			print("hit")
		else:
			print("missed")
	
		if not canMoveOnAttack:
			canMove = true;
		$AnimatedSprite.modulate = currentColor;
		isAttacking = false;
		yield(get_tree().create_timer(attackCooldown),"timeout");
		canAttack = true;
	

