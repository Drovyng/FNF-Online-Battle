function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'SansOrange' then
			
			if difficultyName == "hard" then
			
				setPropertyFromGroup('unspawnNotes', i, 'texture', 'OBONE_assets');
				
			else
		
				if downscroll then
					setPropertyFromGroup('unspawnNotes', i, 'noteAnimSuffix', " downscroll");
					setPropertyFromGroup('unspawnNotes', i, 'offsetY', -142.8);
				end
				
				setPropertyFromGroup('unspawnNotes', i, 'texture', 'NightmareOrangeNotes');
				setPropertyFromGroup('unspawnNotes', i, 'offsetX', -44.5);
			
			end
			
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashDisabled', true);
		end
	end
end

local killTimer = 0;

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'SansOrange' and (not isOnline or isPlayer) then
		killTimer = killTimer + 1
	end
end

function onUpdate(elapsed)
	
	if killTimer > 0 then
	
		if difficultyName == "hard" then
		
			killTimer = killTimer - elapsed
			addHealth(-elapsed)
		
		else
		
			killTimer = killTimer - elapsed * 2
			addHealth(-elapsed * 3)

		end
	end
end
