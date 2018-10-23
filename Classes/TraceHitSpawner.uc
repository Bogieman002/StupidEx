//=============================================================================
// TraceHitSpawner class so we can reduce nettraffic for hitspangs
//=============================================================================
class TraceHitSpawner extends Actor;

// Stupid Ex: Import these using 'ucc build'.
/*
#exec AUDIO IMPORT FILE="Sounds\Generic\SERicochet1.wav"		NAME="SERicochet1"		GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\SERicochet2.wav"		NAME="SERicochet2"		GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\SEArmorRicochet.wav"		NAME="SEArmorRicochet"		GROUP="Generic"
*/

var float HitDamage;
var bool bPenetrating; // shot that hit was a penetrating shot
var bool bHandToHand;  // shot that hit was hand to hand
var bool bInstantHit;
var Name damageType;
// Stupid Ex: Clean up ricochet code a bit, adding in material based sounds
var Sound ricochetSounds[8];
var Sound softRicochetSounds[2];
var Sound glassRicochetSounds[4];
var Sound woodRicochetSounds[4];
var Sound armorRicochetSounds[3];

simulated function PostBeginPlay()
{
   Super.PostBeginPlay();
   
   if (Owner == None)
      SetOwner(Level);
   SpawnEffects(Owner,HitDamage);
}

simulated function Timer()
{
   Destroy();
}

// ----------------------------------------------------------------------
// GetMaterial()
//
// Gets the name of the texture group that we hit.
// ----------------------------------------------------------------------

function name GetMaterial()
{
	local vector EndTrace,StartTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;

	// trace down to our feet
	EndTrace = Location + Vector(Rotation)*-10;
	StartTrace = Location + Vector(Rotation)*16;

	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace,StartTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
			break;
	}

	return texGroup;
}

//
// we have to use an actor to play the hit sound at the correct location
//
simulated function PlayHitSound(actor destActor, Actor hitActor)
{
	local float rnd;
	local sound snd, snd2;
	local name mat;

	// don't ricochet unless it's hit by a bullet
	// if ((damageType != 'Shot') && (damageType != 'Sabot'))
	// 	return;

	// Vanilla Matters: Fix a bug with ricochet sounds not playing correctly.

	rnd = FRand();
	mat = GetMaterial();
	snd2 = None;

	// Stupid Ex: Add in about... 4 more ricochet sounds, and clean up the code.

	/*
	if (rnd < 0.25)
		snd = sound'Ricochet1';
	else if (rnd < 0.5)
		snd = sound'Ricochet2';
	else if (rnd < 0.75)
		snd = sound'Ricochet3';
	else
		snd = sound'Ricochet4';
	*/
	/*
	if (rnd < 0.125)
		snd = ricochetSounds[0];
	else if (rnd < 0.25)
		snd = ricochetSounds[1];
	else if (rnd < 0.375)
		snd = ricochetSounds[2];
	else if (rnd < 0.5)
		snd = ricochetSounds[3];
	else if (rnd < 0.625)
		snd = ricochetSounds[4];
	else if (rnd < 0.75)
		snd = ricochetSounds[5];
	else if (rnd < 0.875)
		snd = ricochetSounds[6];
	else
		snd = ricochetSounds[7];
	*/

	snd = RicochetSounds[ Rand( 7 ) ];

	// play a different ricochet sound if the object isn't damaged by normal bullets
	if (hitActor != None) 
	{
		/*
		if (hitActor.IsA('DeusExDecoration') && (DeusExDecoration(hitActor).minDamageThreshold > 10))
			snd = sound'ArmorRicochet';
		else if (hitActor.IsA('Robot'))
			snd = sound'ArmorRicochet';
		*/
		if ((hitActor.IsA('DeusExDecoration') && (DeusExDecoration(hitActor).minDamageThreshold > 10)) || (hitActor.IsA('Robot')))
		{
			/*
			if (rnd < 0.3)
				snd = armorRicochetSounds[0];
			else if (rnd < 0.6)
				snd = armorRicochetSounds[1];	
			else
				snd = armorRicochetSounds[2];
			*/
			snd = armorRicochetSounds[ Rand( 2 ) ];
		}
		switch(mat)
		{
			case 'Textile':
			case 'Paper':
			case 'Foliage':
			case 'Earth':
				snd2 = softRicochetSounds[ Rand( 1 ) ];
				break;
			case 'Metal':
			case 'Ladder':
				snd2 = armorRicochetSounds[ Rand( 2 ) ];
				break;
			case 'Ceramic':
			case 'Glass':
			case 'Tiles':
				snd2 = glassRicochetSounds[ Rand( 3 ) ];
				break;
			case 'Wood':
				snd2 = woodRicochetSounds[ Rand( 3 ) ];	
				break;
			case 'Brick':
			case 'Concrete':
			case 'Stone':
			case 'Stucco':
			default:
				break;
		}
	}
	if (destActor != None)
	{
		destActor.PlaySound(snd, SLOT_None,,, 1024, 1.1 - 0.2*FRand());
		destActor.PlaySound(snd2, SLOT_None,0.75,, 1024, 1.1 - 0.2*FRand());		
	}
}

simulated function SpawnEffects(Actor Other, float Damage)
{
	local SmokeTrail puff;
	local int i;
	local BulletHole hole;
	local RockChip chip;
	local Rotator rot;
	local DeusExMover mov;
	local Spark		spark;
	local name mat;

   SetTimer(0.1,False);
   if (Level.NetMode == NM_DedicatedServer)
      return;
	  
	mat = GetMaterial();

	if (bPenetrating && !bHandToHand && !Other.IsA('DeusExDecoration'))
	{
		// Every hit gets a puff in multiplayer
		// if ( Level.NetMode != NM_Standalone )
		// {
		// 	puff = spawn(class'SmokeTrail',,,Location+(Vector(Rotation)*1.5), Rotation);
		// 	if ( puff != None )
		// 	{
		// 		puff.DrawScale = 1.0;
		// 		puff.OrigScale = puff.DrawScale;
		// 		puff.LifeSpan = 1.0;
		// 		puff.OrigLifeSpan = puff.LifeSpan;
  //           puff.RemoteRole = ROLE_None;
		// 	}
		// }
		// else
		// {
		// 	if (FRand() < 0.5)
		// 	{
		// 		puff = spawn(class'SmokeTrail',,,Location+Vector(Rotation), Rotation);
		// 		if (puff != None)
		// 		{
		// 			puff.DrawScale *= 0.3;
		// 			puff.OrigScale = puff.DrawScale;
		// 			puff.LifeSpan = 0.25;
		// 			puff.OrigLifeSpan = puff.LifeSpan;
  //              puff.RemoteRole = ROLE_None;
		// 		}
		// 	}
		// }

		// Vanilla Matters: Gotta make them puffs.
		puff = spawn( class'SmokeTrail',,, Location + ( Vector( Rotation ) * 1.5 ), Rotation );
		if ( puff != None ) {
			puff.DrawScale = 0.2;
			puff.OrigScale = puff.DrawScale;
			puff.LifeSpan = 1.0;
			puff.OrigLifeSpan = puff.LifeSpan;
        	puff.RemoteRole = ROLE_None;
		}

		if (!Other.IsA('DeusExMover'))
		{
            if (FRand() < 0.8)
            {
/*
               chip = spawn(class'Rockchip',,,Location+Vector(Rotation));
*/
				switch(mat)
				{
					case 'Foliage':
					case 'Metal':
					case 'Ladder':
					case 'Ceramic':
					case 'Glass':
					case 'Tiles':
						break;
					case 'Textile':
					case 'Paper':
						chip = spawn(class'Paperchip',,,Location+Vector(Rotation));
						break;
					case 'Wood':
						chip = spawn(class'Woodchip',,,Location+Vector(Rotation));
						break;						
					case 'Brick':
					case 'Concrete':
					case 'Stone':
					case 'Earth':
					case 'Stucco':
					default:
						chip = spawn(class'Rockchip',,,Location+Vector(Rotation));
						break;
				}
				if (chip != None)
					chip.RemoteRole = ROLE_None;
            }
		}
	}

   if ((!bHandToHand) && bInstantHit && bPenetrating)
	{
      hole = spawn(class'BulletHole', Other,, Location+Vector(Rotation), Rotation);
      if (hole != None)      
         hole.RemoteRole = ROLE_None;

		if ( !Other.IsA('DeusExPlayer') )		// Sparks on people look bad
		{
			spark = spawn(class'Spark',,,Location+Vector(Rotation), Rotation);
			if (spark != None)
			{
				spark.RemoteRole = ROLE_None;
				if ( Level.NetMode != NM_Standalone )
					spark.DrawScale = 0.25;
				else
					spark.DrawScale = 0.05;
				PlayHitSound(spark, Other);
			}
		}
	}

	// draw the correct damage art for what we hit
	if (bPenetrating || bHandToHand)
	{
		if (Other.IsA('DeusExMover'))
		{
			mov = DeusExMover(Other);
			if ((mov != None) && (hole == None))
         {
            hole = spawn(class'BulletHole', Other,, Location+Vector(Rotation), Rotation);
            if (hole != None)
               hole.remoteRole = ROLE_None;
         }

			if (hole != None)
			{
				if (mov.bBreakable && (mov.minDamageThreshold <= Damage))
				{
					// don't draw damage art on destroyed movers
					if (mov.bDestroyed)
						hole.Destroy();
					else if (mov.FragmentClass == class'GlassFragment')
					{
						// glass hole
						if (FRand() < 0.5)
							hole.Texture = Texture'FlatFXTex29';
						else
							hole.Texture = Texture'FlatFXTex30';

						hole.DrawScale = 0.1;
						hole.ReattachDecal();
					}
					else
					{
						// non-glass crack
						if (FRand() < 0.5)
							hole.Texture = Texture'FlatFXTex7';
						else
							hole.Texture = Texture'FlatFXTex8';

						hole.DrawScale = 0.4;
						hole.ReattachDecal();
					}
				}
				else
				{
					if (!bPenetrating || bHandToHand)
						hole.Destroy();
				}
			}
		}
	}
}

defaultproperties
{
     HitDamage=-1.000000
     bPenetrating=True
     bInstantHit=True
     RemoteRole=ROLE_None
     DrawType=DT_None
     bGameRelevant=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
	 ricochetSounds(0)=Sound'DeusExSounds.Generic.Ricochet1'
	 ricochetSounds(1)=Sound'DeusExSounds.Generic.Ricochet2'
	 ricochetSounds(2)=Sound'DeusExSounds.Generic.Ricochet3'
	 ricochetSounds(3)=Sound'DeusExSounds.Generic.Ricochet4'
	 ricochetSounds(4)=Sound'DeusEx.Generic.Ricochet5'
	 ricochetSounds(5)=Sound'DeusEx.Generic.Ricochet6'
	 ricochetSounds(6)=Sound'DeusEx.Generic.Ricochet7'
	 ricochetSounds(7)=Sound'DeusEx.Generic.Ricochet8'
	 softRicochetSounds(0)=Sound'DeusEx.Generic.SoftRicochet1'
	 softRicochetSounds(1)=Sound'DeusEx.Generic.SoftRicochet2'
	 glassRicochetSounds(0)=Sound'DeusEx.Generic.GlassRicochet1'
	 glassRicochetSounds(1)=Sound'DeusEx.Generic.GlassRicochet2'
	 glassRicochetSounds(2)=Sound'DeusEx.Generic.GlassRicochet3'
	 glassRicochetSounds(3)=Sound'DeusEx.Generic.GlassRicochet4'
	 woodRicochetSounds(0)=Sound'DeusEx.Generic.WoodRicochet1'
	 woodRicochetSounds(1)=Sound'DeusEx.Generic.WoodRicochet2'
	 woodRicochetSounds(2)=Sound'DeusEx.Generic.WoodRicochet3'
	 woodRicochetSounds(3)=Sound'DeusEx.Generic.WoodRicochet4'
	 armorRicochetSounds(0)=Sound'DeusExSounds.Generic.ArmorRicochet'
	 armorRicochetSounds(1)=Sound'DeusEx.Generic.ArmorRicochet2'
	 armorRicochetSounds(2)=Sound'DeusEx.Generic.ArmorRicochet3'
}
