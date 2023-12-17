extends Node

signal completedCurrentAttackAnimation

enum AppliedSkill {
	NONE,
	FIRE,
	WIND,
	BOOMERANG,
}

#Attack related
@onready var comboAttackAnimationSequence = ["swing", "swing1", "swing2"]
@onready var comboAttackIndex = 0
@onready var slashVfx = $SlashVFX

#Skill related
@onready var speed = 800

@onready var appliedSkill = AppliedSkill.WIND
const FIRESKILL = preload("res://Scripts/Abilities/Fire.gd")
const WINDSKILL = preload("res://Scenes/Abilities/Wind.tscn")

#Boomerang Skill
@onready var boomerang = false
@onready var shouldBoomerangReturn = false
#@onready var travelTime = 800

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("select_normal_melee"):
		appliedSkill = AppliedSkill.NONE
		boomerang = false
	if Input.is_action_just_pressed("select_fire_skill"):
		appliedSkill = AppliedSkill.FIRE
		boomerang = false
	if Input.is_action_just_pressed("select_wind_skill"):
		appliedSkill = AppliedSkill.WIND
		boomerang = false
	if Input.is_action_just_pressed("select_boomerang_skill"):
		appliedSkill = AppliedSkill.BOOMERANG
		
func _physics_process(delta):
	if boomerang:
		if not shouldBoomerangReturn:
			$Blade.position += $Blade.transform.x * speed * delta
		else:
			var destination = get_parent().get_parent().position - $Blade.position
			$Blade.position += destination * speed * delta
			
			if destination < get_parent().get_parent().position:
				boomerang = false
				shouldBoomerangReturn = false

func _on_blade_body_entered(body):
	if body.is_in_group("mobs"):
		var hitObj := body as Enemy
		hitObj.takeDamage(15)
		if appliedSkill == AppliedSkill.FIRE:
			var fs = FIRESKILL.new(hitObj)
			hitObj.add_child(fs)
			hitObj.fireNode = fs
			hitObj.setIsOnFire(true)

func swing():
	slashVfx.show()
	$Blade/Swing.play(comboAttackAnimationSequence[comboAttackIndex])
	match appliedSkill:
		AppliedSkill.WIND:
			var ws = WINDSKILL.instantiate()
			get_parent().get_parent().get_parent().add_child(ws)
			ws.transform = $WindSpawnPoint.global_transform
		
		AppliedSkill.BOOMERANG:
			$BoomerangTravelTime.start()
			boomerang = true
	
	if comboAttackIndex == 1:
		slashVfx.flip_h
	
	slashVfx.play()

func _on_slash_vfx_animation_finished():
	slashVfx.hide()

func onCurrentAttackCompleted():
	incrementArrayIndex()
	completedCurrentAttackAnimation.emit()
	
func incrementArrayIndex():
	comboAttackIndex = comboAttackIndex + 1
	if comboAttackIndex == comboAttackAnimationSequence.size():
		comboAttackIndex = 0

func resetCombo():
	comboAttackIndex = 0


func _on_boomerang_travel_time_timeout():
	shouldBoomerangReturn = true
