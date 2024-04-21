function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'CharaAttack' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_CharaAttack_assets');
			setPropertyFromGroup('unspawnNotes', i, 'ratingDisabled', true);
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', isOnline);
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
			setPropertyFromGroup('unspawnNotes', i, 'noHitAnimation', true);
			setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', true);
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', 0);
			setPropertyFromGroup('unspawnNotes', i, 'hitsoundDisabled', true);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashDisabled', true);
			if not getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
				setPropertyFromGroup('unspawnNotes', i, 'offsetAngle', 25);
				setPropertyFromGroup('unspawnNotes', i, 'offsetX', 25);
				setPropertyFromGroup('unspawnNotes', i, 'offsetY', -25);
			end
		end
	end
	
	makeAnimatedLuaSprite('CharaAttackSpr', 'characters/chara_attack', defaultOpponentX - 50, defaultOpponentY + 300)
	addAnimationByIndices('CharaAttackSpr', 'prepare', 'Chara Attack', "0,1,2,3,4,5,6,7", 24, false)
	addAnimationByPrefix('CharaAttackSpr', 'attack', 'Chara Attack', 24, false)
	
	addOffset('CharaAttackSpr', 'prepare', 20, 80)
	addOffset('CharaAttackSpr', 'attack', 10, 90)
	
	addLuaSprite('CharaAttackSpr', true);
	setPropertyLuaSprite('CharaAttackSpr', 'alpha', 0)
	
	makeAnimatedLuaSprite('CharaAttackAlert', 'spacebar', 0, 0)
	addAnimationByPrefix('CharaAttackAlert', 'alert', 'ALERT', 24, true)
	setLuaSpriteCamera('CharaAttackAlert', "camHUD")
	addLuaSprite('CharaAttackAlert', true);
	setPropertyLuaSprite('CharaAttackAlert', 'alpha', 0)
	screenCenter('CharaAttackAlert')
	scaleObject('CharaAttackAlert', 0.55, 0.55, true)
	
	setPropertyFromClass("GameOverSubstate", "deathSoundName", "charaAttack")
	setPropertyFromClass("GameOverSubstate", "endSoundName", "risa_Chara")
end

local dodgeTimer = 0;
local dodgeTimeout = 0;
local dodging = false;
local charaAttackingTime = 0;

function onStepHit()
	if charaAttackingTime > 0 then
		charaAttackingTime = charaAttackingTime - 1
		
		if charaAttackingTime == 6 and getProperty("cpuControlled") then
		
			dodge()
			
		elseif charaAttackingTime == 4 then
		
			playAnim('CharaAttackSpr', 'attack', true, false, 8)
			
		elseif charaAttackingTime == 2 then
		
			if isPlayer and dodgeTimer <= 0 then
				setHealth(0)
				if isOnline then
					sendOnline("bf_charakill", nil)
				end
			end
			setPropertyLuaSprite('CharaAttackAlert', 'alpha', 0)
			
		elseif charaAttackingTime == 0 then
			setPropertyLuaSprite('CharaAttackSpr', 'alpha', 0)
			setProperty("dad.alpha", 1)
		end
	end
end

function onOnlineMessage(id, data)
	if id == "bf_dodge" then
		dodge()
	elseif id == "bf_charakill" then
		setHealth(0)
	elseif id == "chara_atk" then
		chara()
	end
end

function chara()
	if isOnline and not isPlayer then
		sendOnline("chara_atk", nil)
	end
	triggerEvent("Screen Shake", "0.5, 0.01", "0.5, 0.005")
	setPropertyLuaSprite('CharaAttackSpr', 'alpha', 1)
	setProperty("dad.alpha", 0)
	playAnim('CharaAttackSpr', 'prepare', true)
	charaAttackingTime = 16
	playSound('alert')
	setPropertyLuaSprite('CharaAttackAlert', 'alpha', 1)
	playAnim('CharaAttackAlert', 'alert', true)
end

function dodge()
	if isOnline and isPlayer then
		sendOnline("bf_dodge", nil)
	end
	characterPlayAnim("bf", "dodge", true)
	setProperty("boyfriend.specialAnim", true)
	dodgeTimer = 0.58
	dodgeTimeout = dodgeTimer + 0.1
end

function onUpdatePost(elapsed)
	if isPlayer then
		if dodgeTimer > 0 then
			dodgeTimer = dodgeTimer - elapsed
		end
		if dodgeTimeout > 0 then
			dodgeTimeout = dodgeTimeout - elapsed
		end
		if keyboardJustPressed("SPACE") and dodgeTimeout <= 0 and not getProperty("cpuControlled") then
			dodge()
		end
	end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'CharaAttack' and not isSustainNote and (not isPlayer or not isOnline) then
		chara()
	end
end