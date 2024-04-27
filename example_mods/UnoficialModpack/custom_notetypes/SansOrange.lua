function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'SansOrange' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'OBONE_assets');
			
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashDisabled', true);
		end
	end
end

local killTimer = 0;

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'SansOrange' then
		killTimer = killTimer + 1
	end
end

function onUpdate(elapsed)
	if killTimer > 0 then
		killTimer = killTimer - elapsed
		addHealth(-elapsed)
	end
end