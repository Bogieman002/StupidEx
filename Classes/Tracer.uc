//=============================================================================
// Tracer.
//=============================================================================
class Tracer extends DeusExProjectile;

var DeusExPlayer Player;
var float DeltaTime;
var() Sound WhizSounds[5];
var Sound Whizzy;

// Stupid Ex: Add in bullet whizzing noises.

event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	Whizzy = WhizSounds[ Rand( 4 ) ];
}

simulated function Tick(float deltaTime)
{
	// local sound snd;
	// local float rnd;
	
	// rnd = FRand();
	/*
	if (rnd < 0.2)
		snd = Sound'DeusEx.Generic.Whiz1';
	else if (rnd < 0.4)
		snd = Sound'DeusEx.Generic.Whiz2';
	else if (rnd < 0.6)
		snd = Sound'DeusEx.Generic.Whiz3';
	else if (rnd < 0.8)
		snd = Sound'DeusEx.Generic.Whiz4';
	else
		snd = Sound'DeusEx.Generic.Whiz5';
	*/

    Super.Tick(deltaTime);
	
	Player = DeusExPlayer(GetPlayerPawn());
    
    if (VSize(Location - player.Location) < 64)
	{
        PlaySound(Whizzy, SLOT_None,,,, );
		MakeNoise(0.1);
	}
}

defaultproperties
{
     AccurateRange=16000
     maxRange=16000
     bIgnoresNanoDefense=True
     speed=4000.000000
     MaxSpeed=4000.000000
     Mesh=LodMesh'DeusExItems.Tracer'
     ScaleGlow=2.000000
     bUnlit=True
	 WhizSounds(0)=Sound'DeusEx.Generic.Whiz1'
	 WhizSounds(1)=Sound'DeusEx.Generic.Whiz2'
	 WhizSounds(2)=Sound'DeusEx.Generic.Whiz3'
	 WhizSounds(3)=Sound'DeusEx.Generic.Whiz4'
	 WhizSounds(4)=Sound'DeusEx.Generic.Whiz5'
}
