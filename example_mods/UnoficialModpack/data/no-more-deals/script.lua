function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if noteType ~= 'CharaAttack' then
		if (curStep >= 200 and curStep <= 520) or (curStep >= 712 and curStep <= 720) or curStep >= 1080 then
			triggerEvent("Screen Shake", "0.25, 0.01", "0.25, 0.005")
			if not isOnline then
				setHealth(math.max(0.5, getHealth() - 0.03))
			end
		end
		if (curStep >= 770 and curStep < 1080) then
			triggerEvent("Screen Shake", "0.25, 0.005", "0.25, 0.0025")
			if not isOnline then
				setHealth(math.max(0.5, getHealth() - 0.015))
			end
		end
	end
end
function onUpdate()
	if curStep >= 1090 and curStep < 1344 then
		triggerEvent("Screen Shake", "0.1, 0.02", "0.1, 0.01")
	end
end
function onBeatHit()
	if curStep >= 1216 and curStep < 1344 then
		triggerEvent("Add Camera Zoom", "0.05", "0.1")
	end
end