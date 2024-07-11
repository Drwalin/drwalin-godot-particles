@tool
extends Node3D;
class_name Explosion_01;

var emittingF:bool = false;
var emittingS:bool = false;
var emittingSp:bool = false;

func Emit():
	$Fire_01.emitting = true;
	$Smoke.emitting = true;
	$Sparks.emitting = true;
	emittingF = true;
	emittingS = true;
	emittingSp = true;
	$Fire_01.restart();
	$Smoke.restart();
	$Sparks.restart();

func IsEmiting() -> bool:
	return emittingF || emittingS || $Fire_01.emitting || $Smoke.emitting || emittingSp || $Sparks.emitting;

func _SmokeDone():
	emittingS = false;
	
func _FireDone():
	emittingF = false;
	
func _SparksDone():
	emittingSp = false;

func _ready():
	$Smoke.finished.connect(_SmokeDone);
	$Fire_01.finished.connect(_FireDone);
	$Sparks.finished.connect(_SparksDone);
	Emit();


func _process(delta):
	if IsEmiting() == false:
		Emit();
	pass
