function onCreate()

	--[[
	
	alarm = new FlxSprite();
	alarm.frames = Paths.getSparrowAtlas('DodgeMechs', 'sans');

	if (SONG.song.toLowerCase() == 'burning-in-hell')
	{
		alarm.frames = Paths.getSparrowAtlas('Cardodge', 'sans');
	}

	alarm.animation.addByPrefix('play', 'Alarm instance 1', 24, false);
	alarm.animation.addByPrefix('DIE', 'Bones boi instance 1', 24, false);
	alarm.updateHitbox();
	alarm.antialiasing = true;
	alarm.alpha = 0.0001;
	alarm.x = boyfriend.x - 175;
	alarm.y = boyfriend.y - 100;
	add(alarm);
	
	bfDodge = new FlxSprite();
	bfDodge.frames = Paths.getSparrowAtlas('Cardodge', 'sans');
	bfDodge.updateHitbox();
	bfDodge.antialiasing = true;
	bfDodge.alpha = 0.0001;
	bfDodge.x = boyfriend.x;
	bfDodge.y = boyfriend.y + 40;
	add(bfDodge);
	
	]]

	
	makeAnimatedLuaSprite('SansAlarm', 'Cardodge')
	addAnimationByPrefix('SansAlarm', 'play', 'Alarm instance 1', 24, false)
	addAnimationByPrefix('SansAlarm', 'DIE', 'Bones boi instance 1', 24, false)
	
	setPropertyLuaSprite('SansAlarm', 'x', getProperty("boyfriend.x") - 175)
	setPropertyLuaSprite('SansAlarm', 'y', getProperty("boyfriend.y") - 100)
	setPropertyLuaSprite('SansAlarm', 'alpha', 0.0001)
	
	addLuaSprite('SansAlarm', true);

	
	makeAnimatedLuaSprite('BfDodge', 'Cardodge')
	addAnimationByPrefix('BfDodge', 'Dodge', 'Dodge instance 1', 24, false)
	
	setPropertyLuaSprite('BfDodge', 'x', getProperty("boyfriend.x"))
	setPropertyLuaSprite('BfDodge', 'y', getProperty("boyfriend.y") + 40)
	setPropertyLuaSprite('BfDodge', 'alpha', 0.0001)
	
	addLuaSprite('BfDodge', true);
end

local dodged = false;
local attacking = false;
local attackTime = 0;

function onEvent(name, value1, value2)
	--[[
	
	FlxG.sound.play(Paths.sound('notice', 'sans'), 0.6);

	alarm.alpha = 1;
	alarm.animation.play('play', true);

	waitTime = Conductor.crochet / 500;
	
	]]
	if name == "SansDodge" then
		playSound('notice', 0.6)
		dodged = false
		attacking = true
		setPropertyLuaSprite('SansAlarm', 'alpha', 1)
		playAnim('SansAlarm', 'play', true)
		attackTime = 120 / bpm
		--setProperty("camFollow.x", getProperty("camFollow.x") + 200)
	end
end

function onOnlineMessage(id, data)
	if id == "bf_dodge" then
		dodge()
	end
end

function dodge()
	if isPlayer and isOnline then
		sendOnline("bf_dodge", nil)
	end
	playAnim('hud_dodge', 'fuck', true)
	playSound('dodge', 0.6)
	triggerEvent("Screen Shake", "0.02, 0.025", "0.02, 0.025")
	dodged = true
end

function onUpdate(elapsed)
	if attacking == true then
		if attackTime > 0 then
			cameraSetTarget("bf")
			if (keyboardJustPressed("SPACE") and dodged == false) and not getProperty("cpuControlled") then
				playAnim('hud_dodge', 'fuck', true)
				playSound('dodge', 0.6)
				triggerEvent("Screen Shake", "0.02, 0.025", "0.02, 0.025")
				dodged = true
			end
			attackTime = attackTime - elapsed
			if attackTime <= 0 then
				playSound('sansattack', 0.6)
				if dodged == true or getProperty("cpuControlled") then
					if getProperty("boyfriend.specialAnimExtra") == false then
						setProperty('boyfriend.alpha', 0.0001)
						setPropertyLuaSprite('BfDodge', 'alpha', 1)
						playAnim('BfDodge', 'Dodge', true)
					end
				else
					addHealth(-1)
				end
				if mustHitSection == false then 
					cameraSetTarget("dad")
				end
				playAnim('SansAlarm', 'DIE', true)
			end
		elseif getPropertyLuaSprite("SansAlarm", "animation.curAnim.finished") then
			setProperty('boyfriend.alpha', 1)
			setPropertyLuaSprite('BfDodge', 'alpha', 0.0001)
			setPropertyLuaSprite('SansAlarm', 'alpha', 0.0001)
			attacking = false
		end
	end
end