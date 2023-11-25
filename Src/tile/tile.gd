class_name tile extends Node2D

var max_hp :int = 100
var hp : int = 100
var buildState : eBuildState = eBuildState.dead
var hovered = false
var Owner : map
var x :int
var y :int

var buildingHP:int = 5
var buildingHPMax :int = 5
var productionTimeMax = 3
var prodTime = productionTimeMax

var windmillCost = 5
var groundCost = 1

func _ready():
	var anim = $AnimatedSprite2D
	hp = max_hp
	buildingHP = buildingHPMax
	anim.play()
	prodTime = productionTimeMax
	

func _process(delta):
	changeAnimState()
	if buildState ==  eBuildState.windmill:
		prodTime = prodTime - delta
		if prodTime <=0:
			produce()
			prodTime = productionTimeMax

func produce():
	Owner.wind+=1

func _on_area_2d_area_entered(area):
	if  area.owner.get_class() == "CharacterBody2D":
		if area.owner as tsunami:
			if buildState == eBuildState.windmill:
				damageBuilding(area.owner.damage)
				area.owner.queue_free()
		else:
			print("no")
func damageBuilding(damage):
	buildingHP -= damage
	if buildingHP <=0:
		print("dead")
		buildState = eBuildState.none
		changeAnimState()

func _on_area_2d_mouse_entered():
	var rect = $ColorRect
	hovered = true
	rect.visible = true

func _on_area_2d_mouse_exited():
	var rect = $ColorRect
	hovered = false
	rect.visible = false

func _input(event):
	if hovered:
		if Input.is_action_just_pressed("test") && connectedToLand() && canBuild(groundCost,true) && !isGround():
			hp = 500
			buildState = eBuildState.none
			Owner.wind -= groundCost
			changeAnimState()
		if Input.is_action_just_pressed("build") && canBuild(windmillCost):
			buildingHP = buildingHPMax
			buildState = eBuildState.windmill
			Owner.wind -= windmillCost
			changeAnimState()

func canBuild(cost,ignoreLand = false):
	return (buildState != eBuildState.dead||ignoreLand) && buildState != eBuildState.windmill && Owner.wind >= cost

func connectedToLand():
	return Owner.findSurroundingWater(x,y) != 4

func isWater():
	if buildState == eBuildState.dead:
		return true
	else:
		return false

func isGround():
	if buildState != eBuildState.dead:
		return true
	else:
		return false

func erode(water,delta):
	hp = hp-water
	checkDead()
	changeAnimState()

func checkDead():
	if hp <=0:
		buildState = eBuildState.dead

func changeAnimState():
	match buildState:
		eBuildState.dead:
			$Sprite2D.visible=false
			$Sprite2D2.visible=false
		eBuildState.none:
			$Sprite2D.visible = true
			$Sprite2D2.visible=false
		eBuildState.windmill:
			$Sprite2D.visible = true
			$Sprite2D2.visible = true
	
	if isGround() && false:
		$Sprite2D.texture = load("res://Assets/Ground/"+getSurroundingTilesString())
	

func getSurroundingTilesString():
	var grid = Owner.grid
	var out = ""
	if max_hp/hp <2:
		out +="Grass_Edge"
	var e = clamp(x+1,0,Owner.GRID_HORIZ_SIZE-1)
	var w = clamp(x-1,0,Owner.GRID_HORIZ_SIZE-1)
	var n = clamp(y+1,0,Owner.GRID_VERT_SIZE-1)
	var s = clamp(y-1,0,Owner.GRID_VERT_SIZE-1)
	if grid[w][n].isWater():
		out=out + "_NW"
	if grid[x][n].isWater():
		out=out + "_N"
	if grid[e][n].isWater():
		out=out + "_NE"
	if grid[e][x].isWater():
		out=out + "_E"
	if grid[w][n].isWater():
		out=out + "_W"
	if grid[w][s].isWater():
		out=out + "_SW"
	if grid[x][s].isWater():
		out=out + "_S"
	if grid[e][s].isWater():
		out=out + "_SE"
		
		
enum eBuildState{
	none,
	dead,
	windmill
}
