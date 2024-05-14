function onUpdate(elapsed)
	local currentBeat = (getSongPosition() / 1000)*(bpm/60)
	
	if currentBeat < 0 then
		return
	end
	
	-- Reset
	
	for i=0,3 do
		setPropertyFromGroup("playerStrums", i, "x", _G['defaultPlayerStrumX'..i])
		setPropertyFromGroup("playerStrums", i, "y", _G['defaultPlayerStrumY'..i])
		
		setPropertyFromGroup("opponentStrums", i, "x", _G['defaultOpponentStrumX'..i])
		setPropertyFromGroup("opponentStrums", i, "y", _G['defaultOpponentStrumY'..i])
	end
	
	
	if (curStep % 16) < 12 and ((curStep >= 0 and curStep < 124) or curStep >= 2176) then
		
		for i=0,3 do
			setPropertyFromGroup("playerStrums", i, "x", _G['defaultPlayerStrumX'..i] + 25 * math.sin((currentBeat + i*50) * math.pi))
			setPropertyFromGroup("playerStrums", i, "y", _G['defaultPlayerStrumY'..i] + 5 * math.cos((currentBeat + i*0.25) * math.pi))
			
			setPropertyFromGroup("opponentStrums", i, "x", _G['defaultOpponentStrumX'..i] + 25 * math.sin((currentBeat + i*50) * math.pi))
			setPropertyFromGroup("opponentStrums", i, "y", _G['defaultOpponentStrumY'..i] + 5 * math.cos((currentBeat + i*0.25) * math.pi))
		end
	end
	
	if (curStep >= 1152 and curStep < 1216) then
		
		for i=0,3 do
			setPropertyFromGroup("opponentStrums", i, "x", _G['defaultOpponentStrumX'..i] + 25 * math.sin((currentBeat + i*50) * math.pi))
			setPropertyFromGroup("opponentStrums", i, "y", _G['defaultOpponentStrumY'..i] + 5 * math.cos((currentBeat + i*0.25) * math.pi))
		end
	end
	
	if (curStep >= 1216 and curStep < 1280) then
		
		for i=0,3 do
			setPropertyFromGroup("playerStrums", i, "x", _G['defaultPlayerStrumX'..i] + 25 * math.sin((currentBeat + i*50) * math.pi))
			setPropertyFromGroup("playerStrums", i, "y", _G['defaultPlayerStrumY'..i] + 5 * math.cos((currentBeat + i*0.25) * math.pi))
		end
	end
	
	
	-- I HATE IT SO MUCH!!! FUCK IT!!!
	
	-- I HATE IT SO MUCH!!! FUCK IT!!!
	
	-- I HATE IT SO MUCH!!! FUCK IT!!!
	
	-- I HATE IT SO MUCH!!! FUCK IT!!!
	
	-- I HATE IT SO MUCH!!! FUCK IT!!!
	

	if (curStep >= 12 and curStep < 16) or (curStep >= 44 and curStep < 48) or (curStep >= 76 and curStep < 80) or 
	(curStep >= 108 and curStep < 112) or (curStep >= 2188 and curStep < 2192) or (curStep >= 2220 and curStep < 2224) or 
	(curStep >= 2252 and curStep < 2256) or (curStep >= 2284 and curStep < 2288) then
	
		
		for i=0,3 do
			setPropertyFromGroup("playerStrums", i, "y", _G['defaultPlayerStrumY'..i] - 120 * math.cos((currentBeat + i*10) * math.pi))
			setPropertyFromGroup("opponentStrums", i, "y", _G['defaultOpponentStrumY'..i] - 120 * math.cos((currentBeat + i*10) * math.pi))
		end	
	end


	if (curStep >= 28 and curStep < 32) or (curStep >= 60 and curStep < 64) or (curStep >= 92 and curStep < 96) or 
	(curStep >= 124 and curStep < 126) or (curStep >= 2204 and curStep < 2208) or (curStep >= 2236 and curStep < 2240) or
	(curStep >= 2268 and curStep < 2272) or (curStep >= 2300 and curStep < 2302) then
		
		for i=0,3 do
			setPropertyFromGroup("playerStrums", i, "y", _G['defaultPlayerStrumY'..i] + 120 * math.cos((currentBeat + i*10) * math.pi))
			setPropertyFromGroup("opponentStrums", i, "y", _G['defaultOpponentStrumY'..i] + 120 * math.cos((currentBeat + i*10) * math.pi))
		end	
	end
	

	if (curStep >= 640 and curStep < 896) or (curStep >= 1664 and curStep < 2176) then
		for i=0,3 do
			setPropertyFromGroup("playerStrums", i, "y", _G['defaultPlayerStrumY'..i] + 5 * math.cos((currentBeat + i*0.25) * math.pi))
			setPropertyFromGroup("opponentStrums", i, "y", _G['defaultOpponentStrumY'..i] + 5 * math.cos((currentBeat + i*0.25) * math.pi))
		end	
	end
	

	if curStep >= 1024 and curStep < 1154 then
		for i=0,3 do
			setPropertyFromGroup("playerStrums", i, "y", _G['defaultPlayerStrumY'..i] + 25 * math.cos((currentBeat + i*5) * math.pi))
			setPropertyFromGroup("opponentStrums", i, "y", _G['defaultOpponentStrumY'..i] + 25 * math.cos((currentBeat + i*5) * math.pi))
		end	
	end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	triggerEvent("Screen Shake", "0.1, 0.0125", "0.1, 0.0035")
	if not isOnline then
		multy = 1
		if curStep >= 1920 then
			multy = 1.35
		end
		if not isSustainNote then
			multy = multy * 2
		end
		
		
		addHealth(-0.01 * multy)
	end
	characterPlayAnim("gf", "scared", true)
end