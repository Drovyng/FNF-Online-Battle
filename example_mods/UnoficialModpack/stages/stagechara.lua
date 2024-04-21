function onCreate()
	makeLuaSprite('bg1', 'stages/chara_bg', -620, 250);
	--setScrollFactor('bg1', 0.75, 0.75);
	scaleObject('bg1', 2, 2);
	addLuaSprite('bg1', false);
	
	setPropertyFromClass("GameOverSubstate", "characterName", "bf_vschara")
end