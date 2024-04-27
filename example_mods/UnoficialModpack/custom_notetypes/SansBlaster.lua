function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'SansBlaster' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_SansBlaster_assets');
			setPropertyFromGroup('unspawnNotes', i, 'ratingDisabled', true);
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', isOnline);
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
			setPropertyFromGroup('unspawnNotes', i, 'noHitAnimation', true);
			setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', true);
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', 0);
			setPropertyFromGroup('unspawnNotes', i, 'hitsoundDisabled', true);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashDisabled', true);
		end
	end
end