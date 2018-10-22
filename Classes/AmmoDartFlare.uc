//=============================================================================
// AmmoDartFlare.
//=============================================================================
class AmmoDartFlare extends AmmoDart;

// Vanilla Matters: Replacement textures.
// Stupid Ex: Import these using 'ucc build'.
/*
#exec TEXTURE IMPORT FILE="Textures\AmmoDartTex3.bmp"					NAME="AmmoDartTex3"						GROUP="VM" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\BeltIconAmmoDartsInjector.bmp"		NAME="BeltIconAmmoDartsInjector"		GROUP="VMUI" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\LargeIconAmmoDartsInjector.bmp"		NAME="LargeIconAmmoDartsInjector"		GROUP="VMUI" MIPS=Off
*/

defaultproperties
{
     ItemName="Injector Darts"
     Icon=Texture'DeusEx.UserInterface.BeltIconAmmoDartsInjector'
     largeIcon=Texture'DeusEx.UserInterface.LargeIconAmmoDartsInjector'
     Description="Mini-crossbow injector darts are capable of establishing a remote connection to any computer or terminal, disrupting many forms of electronic devices, or causing electronic damage to robots."
     beltDescription="INJ DART"
     Skin=Texture'DeusEx.Skins.AmmoDartTex3'
}
