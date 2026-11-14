extends Node2D

@export var DEFAULT_SPEED := 200
@export var JUMP_IMPULSE := -300;
@export var DASH_IMPULSE := 500
@export var BOUNCE_IMPULSE_X := 300
@export var BOUNCE_IMPULSE_Y := -150

@onready var dash_timer = $DashTimer
@onready var dash_cd = $DashCooldown
@onready var bounce_timer = $BounceTimer
@onready var body = $CharacterBody2D
@onready var skills = $Skills
@onready var stats = $Stats
@onready var UI = %UI

var curr_speed := DEFAULT_SPEED

var dashing = false
var bouncing = false
var dir := 0

func _ready():
	skills.unlock_dash()

func proc_movement(delta):
	var modifier = 1
	
	if not body.is_on_floor():
		modifier = 0.5
		body.velocity.y += body.get_gravity().y * delta
	
	if body.is_on_floor():
		modifier = 1
		if Input.is_action_pressed("jump"):
			body.velocity.y = JUMP_IMPULSE
	
	#if bouncing:
		#body.velocity.y += BOUNCE_IMPULSE_Y * delta
	
	if not bouncing:
		dir = Input.get_axis("move_left", "move_right")
		body.velocity.x = dir * curr_speed * modifier
	else:
		body.velocity.x = -dir * curr_speed
	
func handle_dash(dir: int):
	if not bouncing and Input.is_action_pressed("dash") and skills.can_dash() and not dashing and dash_cd.is_stopped():
		dashing = true
		curr_speed = DASH_IMPULSE
		dash_timer.start()
		
	
func _physics_process(delta: float) -> void:
	proc_movement(delta)	
	handle_dash(dir)
	
	var collision = body.move_and_slide()
	if dashing and collision and not bouncing:
		var collision_body = body.get_last_slide_collision()
		
		for i in body.get_slide_collision_count():
			var J = body.get_slide_collision(i)
		
			if J.get_collider().get_collision_layer() & (1 << 2):
				bounce_timer.start()
				curr_speed = BOUNCE_IMPULSE_X
				bouncing = true

func damage(dmg: int):
	stats.PLAYER_HEALTH -= dmg
	print("health: ", stats.PLAYER_HEALTH)
	UI.get_child(0).text = "Health: " + str(stats.PLAYER_HEALTH)
	if stats.PLAYER_HEALTH <= 0:
		get_tree().reload_current_scene()

func _on_timer_dash_timeout() -> void:
	dashing = false
	curr_speed = DEFAULT_SPEED
	dash_cd.start()

func _on_bounce_timer_timeout() -> void:
	bouncing = false
	curr_speed = DEFAULT_SPEED
