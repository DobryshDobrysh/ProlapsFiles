mwLib.vars = mwLib.vars or {}

netstream.Hook('mwLib.getVars', function(vars)
	local res = {}

	if not istable(vars) then vars = { vars } end
	for i, var in ipairs(vars) do
		res[var] = mwLib.vars.get(var)
	end

	netstream.Start('mwLib.getVars', res)
end)

netstream.Hook('mwLib.setVar', mwLib.setVar)

--
-- some panel helpers
--

local hookFuncs = {
	DComboBox = function(pnl, _var, hName)
		hook.Add('mwLib.setVar', hName, function(var, val)
			if not IsValid(pnl) then
				hook.Remove('mwLib.setVar', hName)
				return
			end

			if var ~= _var then return end
			for i, v in ipairs(pnl.Data) do
				if v == val then
					return pnl:ChooseOptionID(i)
				end
			end
		end)
	end,

	DColorMixer = function(pnl, _var, hName)
		hook.Add('mwLib.setVar', hName, function(var, val)
			if not IsValid(pnl) then
				hook.Remove('mwLib.setVar', hName)
				return
			end

			if var == _var and val ~= pnl:GetColor() then pnl:SetColor(val) end
		end)
	end,

	DTextEntry = function(pnl, _var, hName)
		hook.Add('mwLib.setVar', hName, function(var, val)
			if not IsValid(pnl) then
				hook.Remove('mwLib.setVar', hName)
				return
			end

			if var == _var and val ~= pnl:GetText() then pnl:SetText(val) end
		end)
	end,

	other = function(pnl, _var, hName)
		hook.Add('mwLib.setVar', hName, function(var, val)
			if not IsValid(pnl) then
				hook.Remove('mwLib.setVar', hName)
				return
			end

			if var == _var and pnl:GetValue() ~= val then pnl:SetValue(val) end
		end)
	end,
}

local nextPanelID = 1
local function setupHooks(pnl, _var)
	pnl.cdev3VarID = nextPanelID
	nextPanelID = nextPanelID + 1

	local hName = 'mwLib.panel' .. pnl.cdev3VarID
	local addHook = hookFuncs[pnl:GetTable().ThisClass] or hookFuncs.other

	addHook(pnl, _var, hName)
	pnl.OnRemove = function() hook.Remove('mwLib.setVar', hName) end
end

function mwLib.vars.slider(pnl, var, txt, min, max, prc)
	local e = mwLib.slider(pnl, txt, min, max, prc)
	e:SetValue(tonumber(mwLib.vars.get(var)) or min)
	e.OnValueChanged = function(self, val)
		mwLib.vars.set(var, math.Round(val, prc))
	end
	setupHooks(e, var)

	return e
end

function mwLib.vars.checkBox(pnl, var, txt)
	local e = mwLib.checkBox(pnl, txt)
	e:SetValue(mwLib.vars.get(var) or false)
	e.OnChange = function(self, val)
		mwLib.vars.set(var, val)
	end
	setupHooks(e, var)

	return e
end

function mwLib.vars.textEntry(pnl, var, txt)
	local e, t = mwLib.textEntry(pnl, txt)
	e:SetUpdateOnType(true)
	e:SetValue(tostring(mwLib.vars.get(var)) or '')
	e.OnValueChange = function(self, val)
		mwLib.vars.set(var, val)
	end
	setupHooks(e, var)

	return e, t
end

function mwLib.vars.comboBox(pnl, var, txt, choices)
	choices = choices or {}
	local curVar = mwLib.vars.get(var)
	for i, v in ipairs(choices) do
		v[3] = curVar == v[2]
	end

	local e, t = mwLib.comboBox(pnl, txt, choices)
	e.OnSelect = function(self, i, name, val)
		mwLib.vars.set(var, val)
	end
	setupHooks(e, var)

	return e, t
end

function mwLib.vars.binder(pnl, var, txt, value)
	local e, t = mwLib.binder(pnl, txt, value)
	e:SetValue(tonumber(mwLib.vars.get(var)) or 0)
	e.OnChange = function(self, val)
		mwLib.vars.set(var, tonumber(val))
	end
	setupHooks(e, var)

	return e, t

end

function mwLib.vars.colorPicker(pnl, var, txt, alpha, palette)
	local e, t = mwLib.colorPicker(pnl, txt, alpha, palette)
	e:SetColor(mwLib.vars.get(var) or Color(255,255,255))
	e.ValueChanged = function(self, val)
		if mwLib.vars.get(var) ~= val then
			mwLib.vars.set(var, val)
		end
	end
	setupHooks(e, var)

	return e, t
end