//=============================================================================
// Cigarettes.
//=============================================================================
class Cigarettes extends DeusExPickup;

// Vanilla Matters
var travel int timesPuffed;		// Checks for how many times the smoke puff has appeared.
var travel Actor user;		// The pawn who used this because we're gonna make it disappear.

var localized string VM_msgCantSmoke;

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	// function BeginState()
	// {
	// 	local Pawn P;
	// 	local vector loc;
	// 	local rotator rot;
	// 	local SmokeTrail puff;
		
	// 	Super.BeginState();

	// 	P = Pawn(Owner);
	// 	if (P != None)
	// 	{
	// 		P.TakeDamage(5, P, P.Location, vect(0,0,0), 'PoisonGas');
	// 		loc = Owner.Location;
	// 		rot = Owner.Rotation;
	// 		loc += 2.0 * Owner.CollisionRadius * vector(P.ViewRotation);
	// 		loc.Z += Owner.CollisionHeight * 0.9;
	// 		puff = Spawn(class'SmokeTrail', Owner,, loc, rot);
	// 		if (puff != None)
	// 		{
	// 			puff.DrawScale = 1.0;
	// 			puff.origScale = puff.DrawScale;
	// 		}
	// 		PlaySound(sound'MaleCough');
	// 	}

	// 	UseOnce();
	// }

	// Vanilla Matters: Makes the smoke puff appear over time and do damage.
	function Timer() {
		local Pawn P;
		local DeusExPlayer player;

		local vector loc;
		local rotator rot;
		local SmokeTrail puff;

		P = Pawn( user );
		player = DeusExPlayer( user );

		if ( P != None ) {
			if ( ( player != None && ( player.HeadRegion.Zone.bWaterZone || player.UsingChargedPickup( class'Rebreather' ) ) ) || timesPuffed >= 10 ) {
				SetTimer( 3.0, false );

				bActive = false;

				UseOnce();
			}

			loc = user.Location;
			rot = user.Rotation;
			loc += 2.0 * user.CollisionRadius * vector( P.ViewRotation );
			loc.Z += user.CollisionHeight * 0.9;
			puff = Spawn( class'SmokeTrail', user,, loc, rot );

			if (puff != None)
			{
				puff.DrawScale = 1.0;
				puff.origScale = puff.DrawScale;
			}

			if ( timesPuffed % 2 == 0 ) {
				P.TakeDamage( 1, P, P.Location, vect( 0,0,0 ), 'PoisonGas' );
			}

			if ( Rand( 3 ) > 0 ) {
				PlaySound( sound'MaleCough' );
			}

			timesPuffed = timesPuffed + 1;
		}
	}

	function BeginState() {
		local DeusExPlayer player;

		user = Owner;

		player = DeusExPlayer( Owner );

		if ( player != None ) {
			// VM: Prevents smoking while swimming or using Rebreather.
			if ( player.HeadRegion.Zone.bWaterZone || player.UsingChargedPickup( class'Rebreather' ) ) {
				player.ClientMessage( VM_msgCantSmoke );

				user = None;

				Super.Activate();

				return;
			}

			Super.BeginState();

			timesPuffed = 0;

			bActive = true;

			SetTimer( 3.0, true );

			player.DeleteInventory( self );
		}
	}
Begin:
}

defaultproperties
{
     VM_msgCantSmoke="You cannot smoke right now"
     maxCopies=20
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Cigarettes"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Cigarettes'
     PickupViewMesh=LodMesh'DeusExItems.Cigarettes'
     ThirdPersonMesh=LodMesh'DeusExItems.Cigarettes'
     Icon=Texture'DeusExUI.Icons.BeltIconCigarettes'
     largeIcon=Texture'DeusExUI.Icons.LargeIconCigarettes'
     largeIconWidth=29
     largeIconHeight=43
     Description="'COUGHING NAILS -- when you've just got to have a cigarette.'"
     beltDescription="CIGS"
     Mesh=LodMesh'DeusExItems.Cigarettes'
     CollisionRadius=5.200000
     CollisionHeight=1.320000
     Mass=2.000000
     Buoyancy=3.000000
}