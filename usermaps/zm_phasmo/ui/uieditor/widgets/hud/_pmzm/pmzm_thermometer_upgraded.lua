CoD.PmzmThermometerUpgraded = InheritFrom(LUI.UIElement)

function CoD.PmzmThermometerUpgraded.new(HudRef, InstanceRef)
	local Elem = LUI.UIElement.new()

	local TopLevelModel = Engine.CreateModel(
		Engine.GetModelForController(InstanceRef),
		"hudItems.pmzmThermometerUpgraded"
	)
	local ModelCelsius = Engine.CreateModel(TopLevelModel, "celsius")
	Engine.SetModelValue(ModelCelsius, 0.000000)
	Engine.SetModelValue(ModelDisplayPose, "0 0 0 0 0")

	Elem:setUseStencil(false)
	Elem:setClass(CoD.PmzmThermometerUpgraded)
	Elem.id = "PmzmThermometerUpgraded"
	Elem.soundSet = "default"
	Elem:setLeftRight(true, true, 0, 0)
	Elem:setTopBottom(true, true, 0, 0)
	Elem.anyChildUsesUpdateState = true

	Elem.CelsiusText = LUI.UIText.new()
	Elem.CelsiusText:setLeftRight(true, false, 20, 50)
	Elem.CelsiusText:setTopBottom(true, false, 20, 50)
	Elem.CelsiusText:setTTF("fonts/WEARETRIPPINShort.ttf")
	Elem.CelsiusText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_RIGHT)
	Elem.CelsiusText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_CENTER)
	Elem.CelsiusText:setText("--.-°C")

	local function CelsiusCallback(ModelRef)
		local newText = ""
		local celsiusModelValue = Engine.GetModelValue(ModelRef)
		if celsiusModelValue then
			-- Conversion from constants in pmzm_thermometer.gsh
			newText = string.format("%.1f", (celsiusModelValue * 0.1) - 5.0) .. "°C"
		end
		Elem.CelsiusText:setText(newText)
	end

	HudRef:subscribeToModel(
		Engine.GetModel(
			Engine.GetModelForController(InstanceRef),
			"hudItems.pmzmThermometerUpgraded.celsius"
		),
		CelsiusCallback
	)

	Elem:addElement(Elem.CelsiusText)

	local function PmzmThermometerUpgradedCloseCallback(SenderObj)
		SenderObj.CelsiusText:close()
	end
	LUI.OverrideFunction_CallOriginalSecond(
		Elem,
		"close",
		PmzmThermometerUpgradedCloseCallback
	)

	return Elem
end
