function InitialStacks(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local modifier = "modifier_frostivus_spirit_radiant"

	local target_level = target:GetLevel() 

	target:SetModifierStackCount(modifier, ability, target_level)

end