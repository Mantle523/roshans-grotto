function InitialStacks(keys)

	print("running")

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local modifier = "modifier_frostivus_spirit_dire"

	local target_level = target:GetLevel() 

	target:SetModifierStackCount(modifier, ability, target_level)
	
end