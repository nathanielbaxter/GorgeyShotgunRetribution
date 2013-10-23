// Handles the pickup and dropping of shotguns by gorges.
//
// Performs the same tasks as the lua/MarinActionFinderMixin.lua mixin,
// and the input HandleButtons method from lua/Marine.lua
// Not implemented as a mixin because it's easier not to.

local kPickupWeaponTimeLimit = 1
local kFindWeaponRange = 2
local kIconUpdateRate = 0.5

// Find the nearest dropped shotgun, if there is one.
local function FindNearbyShotgun(self, toPosition)

    local nearbyShotguns = GetEntitiesWithMixinWithinRange("Shotgun", toPosition, kFindWeaponRange)
    local closestShotgun = nil

    for i, nearbyShotgun in ipairs(nearbyShotguns) do

		closestShotgun = nearbyShotgun

    end

    return closestShotgun

end

function Gorge:GetNearbyPickupableShotgun()
    return FindNearbyShotgun(self, self:GetOrigin())
end

// Handle user pickup input on the server side.
if Server

    old_Gorge_OnCreate = Gorge.OnCreate

    function Gorge:OnCreate()

		old_Gorge_OnCreate(self)

		self.timeOfLastPickUpWeapon = 0

    end

	old_Gorge_HandleButtons = Gorge.HandleButtons

	function Gorge:HandleButtons(input)

		old_Gorge_HandleButtons(self, input)

		// Try to digest a shotgun, not something even the most elegant gorgey can do while sliding!
		if bit.band(input.commands, Move.Drop) ~= 0 and not self:GetIsBellySliding() then

			// First check for a nearby shotgun to pickup.
			local nearbyDroppedShotgun = self:GetNearbyPickupableShotgun()
			if nearbyDroppedShotgun then

				if Shared.GetTime() > self.timeOfLastPickUpWeapon + kPickupWeaponTimeLimit then

					// Digest the shottie so that the gorge can use it.
					self:DigestShotgun(nearbyDroppedShotgun)

					self:AddWeapon(nearbyDroppedShotgun, true)
					StartSoundEffectAtOrigin(Marine.kGunPickupSound, self:GetOrigin())

					self.timeOfLastPickUpWeapon = Shared.GetTime()

				end

			else

				// Undo the gorges Digestion of the shottie.
				self.CleanShotgun(nearbyDroppedShotgun)

				// No nearby weapon, drop our current weapon.
				self:Drop()

			end

		end

	end

end

// Handle the pickup gui on the client side.
if Client then

    old_Gorge_OnCreate = Gorge.OnCreate

    function Gorge:OnCreate()

		old_Gorge_OnCreate(self)

		self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
        self.actionIconGUI:SetColor(kAlienFontColor)
        self.lastGorgeActionFindTime = 0

    end

    old_Gorge_OnDestroy = Gorge.OnDestroy

    function Gorge:OnDestroy()

        GetGUIManager():DestroyGUIScript(self.actionIconGUI)
        self.actionIconGUI = nil

        old_Gorge_OnDestroy(self)

    end

	old_Gorge_OnProcessMove = Gorge.OnProcessMove

    function Gorge:OnProcessMove(input)

		old_Gorge_OnProcessMove(self, input)

        local gameStarted = self:GetGameStarted()
        local prediction = Shared.GetIsBellySliding()
        local now = Shared.GetTime()
        local enoughTimePassed = (now - self.lastGorgeActionFindTime) >= kIconUpdateRate

        if not prediction and enoughTimePassed then

            self.lastGorgeActionFindTime = now

            local success = false

            if self:GetIsAlive() and not GetIsVortexed(self) then

                local foundNearbyShotgun = self:GetNearbyPickupableShotgun()
                if gameStarted and foundNearbyShotgun then

                    self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Drop"), foundNearbyShotgun:GetClassName(), nil)
                    success = true

                end

            end

            if not success then
                self.actionIconGUI:Hide()
            end

        end

    end

end
