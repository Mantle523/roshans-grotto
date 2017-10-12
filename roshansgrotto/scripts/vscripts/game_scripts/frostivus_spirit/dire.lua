function InitialStacks(keys)

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local modifier = "modifier_frostivus_spirit_dire"

	local target_level = target:GetLevel() 

	target:SetModifierStackCount(modifier, ability, target_level)
	
end

function RemoveStacks( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local modifier = "modifier_frostivus_spirit_dire"
	local stacks = target:GetModifierStackCount(modifier, ability)

	if target:HasModifier(modifier) then
		target:SetModifierStackCount(modifier, ability, stacks - 1)
		stacks = target:GetModifierStackCount(modifier, ability)

		if stacks == 0 then
			target:RemoveModifierByName(modifier)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_rg_pacifier_good", nil) 
		end
	
		else if ability:ApplyDataDrivenModifier(caster, target, "modifier_rg_pacifier_bad", nil) then
		end
	end
end