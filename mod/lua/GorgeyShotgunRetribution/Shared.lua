// Load sub scripts required by this mod, and handles some basic
// general scripting.

Script.Load('lua/GorgeyShotgunRetribution/GorgeShotgunFinder.lua')
Script.Load('lua/GorgeyShotgunRetribution/GorgeShotgun.lua')


// Destory any digested shotgun when the gorge dies. Marines haven't yet 
// learnt how to clean a shottie once it's been digested by a gorge.

old_Gorge_OnKill = Gorge.OnKill

function Gorge:OnKill(attacker, doer, point, direction)

	self:DestroyWeapons()

	old_Gorge_OnKill(self, attacker, doer, point, direction)

end
