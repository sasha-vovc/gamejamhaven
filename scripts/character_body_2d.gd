extends CharacterBody2D
var direction = Vector2(1,0)
@export var speed = 100
@onready var ray_cast_right_wall: RayCast2D = $RayCastRightWall
@onready var ray_cast_left_wall: RayCast2D = $RayCastLeftWall
@onready var ray_cast_right_player: RayCast2D = $RayCastRightPlayer
@onready var ray_cast_left_player: RayCast2D = $RayCastLeftPlayer
@onready var dash_timer: Timer = $"Dash Timer"
@onready var cooldown_timer: Timer = $CooldownTimer

var can_dash = true
var hit_point: Vector2
var distance_to_hit: float
func dash():
	if can_dash:
		speed = 300
		dash_timer.start()
		can_dash = false
	

func _physics_process(delta: float) -> void:
	if ray_cast_left_wall.is_colliding() and direction.x < 0:
		direction.x = 1
	if ray_cast_right_wall.is_colliding() and direction.x > 0:
		direction.x = -1 
	
	if ray_cast_left_player.is_colliding():
		hit_point = ray_cast_left_player.get_collision_point()
		distance_to_hit = global_position.distance_to(hit_point)
		if distance_to_hit > 10: 
			direction.x = -1
		else:
			direction.x = 0
		dash()
	if ray_cast_right_player.is_colliding():
		hit_point = ray_cast_right_player.get_collision_point()
		distance_to_hit = global_position.distance_to(hit_point)
		if distance_to_hit > 10: 
			direction.x = 1
		else:
			direction.x = 0
		dash()
		
	

	velocity.x = direction.x * speed;
	velocity += get_gravity()
	
	move_and_slide()


func _on_dash_timer_timeout() -> void:
	speed = 100
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	can_dash = true
	
