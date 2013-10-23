// Handles the modification of shotguns, to work with the gorge class.
// Attempts to make shotguns like a subclass of the Ability class.
// 
// This script provides two functions, the first overrides functions from
// the Shotgun class, so that the given Shotgun instance works correctly
// as the active weapon for gorges. The second function reverts these
// change, so that marines can pick the shotgun up again, and use it as
// they normally would.

Script.Load('lua/Weapons/Alien/Ability.lua')
Script.Load('lua/Weapons/Marine/Shotgun.lua')

// Inject the isDigested variable into the shotgun class.
old_Shotgun_OnCreate = Shotgun.OnCreate

function Shotgun:OnCreate()
	old_Shotgun_OnCreate(self)

	// Normally one would expect that gorges can't manufacture shotties.
	shotgun.isDisgested = false
end


// Digest a shotgun, making it usable by the gorge.
// Should be the inverse of the Gorge:CleanShotgun function.
function Gorge:DigestShotgun(shotgun)

	if shotgun:isa("Shotgun") and not shotgun.isDigested

		shotgun.isDisgested = true

		// Edit the shotgun's hud location so it works for gorges.
		shotgun:GetHUDSlot = function ()
			return 5
		end

		/*// Clear the shotgun animation cycle.
		shotgun:GetAnimationGraphName = function ()
			return nil
		end

		// Alien ability method overrides
		shotgun.GetResetViewModelOnDraw = Ability.GetResetViewModelOnDraw
		shotgun.GetWorldModelName = Ability.GetWorldModelName
		shotgun.GetViewModelName = Ability.GetViewModelName
		shotgun.OnDraw = Weapon.OnDraw

		// Clear the shotgun model.
		// shotgun:SetModel(nil, nil)*/

	end

end

// Drop a shotgun, making it usable by marines again.
// Should be the inverse of the Gorge:DigestShotgun function.
function Gorge:CleanShotgun(shotgun)

	if shotgun:isa("Shotgun") and shotgun.isDigested

		shotgun.isDisgested = false

		// Revert all modified functions back to their originals.
		//self:SetIsVisible(true)
		//self.isHolstered = false

		shotgun.GetHUDSlot = Shotgun.GetHUDSlot
		//shotgun.OnDraw = Shotgun.OnDraW
		//shotgun:SetModel(Shotgun.kModelName, Shotgun:GetAnimationGraphName())

	end

end
