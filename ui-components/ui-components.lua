local uiComponents = {}
local uikit = require("uikit")
local ease = require("ease")

uiComponents.countDownAnimated = function(position, onCountdownDone)
    local text = uikit:createText("3", Color.Black, "big")
	text.object.Anchor = { 0.5, 0.5 }
	text.parentDidResize = function() text.pos = position end
	text:parentDidResize()

	local textCopy = uikit:createText("3", Color.White, "big")
	textCopy.object.Anchor = { 0.5, 0.5 }
	textCopy.LocalPosition.Z = -1
	textCopy.parentDidResize = function() textCopy.pos = position end
	textCopy:parentDidResize()

	local animateCountdown = function(textNode, textCopyNode, color, textValue, callback)
		textNode.object.Scale = Number3(0, 0, 0)
		textNode.Color = color
		textNode.Text = textValue
		ease:outElastic(textNode.object, 1.0).Scale = Number3(6, 6, 6)

		textCopyNode.object.Scale = Number3(0, 0, 0)
		textCopyNode.Color = Color(60, 60, 60)
		textCopyNode.Text = textValue
		ease:outElastic(textCopyNode.object, 1.0, { onDone = callback }).Scale = Number3(7, 7, 7)
	end

	local as = AudioSource()
	as.Sound = "laser_gun_shot_1"
	as:SetParent(Player.Head)
	as.Volume = 0.7
	as.Pitch = 1.8
	as:Play()

	animateCountdown(text, textCopy, Color.Red, "3", function()
		as:Play()
		animateCountdown(text, textCopy, Color.Green, "2", function()
			as:Play()
			animateCountdown(text, textCopy, Color.Blue, "1", function()
				as.Pitch = 4.0
				as:Play()
                onCountdownDone()

				animateCountdown(text, textCopy, Color(255, 128, 0), "Go!", function()
					text:hide()
					textCopy:hide()
				end)
			end)
		end)
	end)
end

return uiComponents
