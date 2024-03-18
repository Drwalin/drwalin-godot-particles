@tool
extends Node3D;
class_name Explosion_01;

var emittingF:bool = false;
var emittingS:bool = false;

func Emit():
	$Fire_01.emitting = true;
	$Smoke.emitting = true;
	emittingF = true;
	emittingS = true;
	$Fire_01.restart();
	$Smoke.restart();

func IsEmiting() -> bool:
	return emittingF || emittingS || $Fire_01.emitting || $Smoke.emitting;

func _SmokeDone():
	emittingS = false;
	
func _FireDone():
	emittingF = false;

func _ready():
	$Smoke.finished.connect(_SmokeDone);
	$Fire_01.finished.connect(_FireDone);
	Emit();


func _process(delta):
	if IsEmiting() == false:
		Emit();
	pass
