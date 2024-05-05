function onCreate()

	makeAnimatedLuaSprite('SansAlarm', 'Sans_Shit_NM')
	
	addAnimationByPrefix('SansAlarm', 'playBlue', 'AlarmBlue instance 1', 24, false)
	addAnimationByPrefix('SansAlarm', 'dieBlue', 'Bones boi instance 1', 24, false)
	
	addAnimationByPrefix('SansAlarm', 'playOrange', 'AlarmOrange instance 1', 24, false)
	addAnimationByPrefix('SansAlarm', 'dieOrange', 'Bones Orange instance 1', 24, false)
	
	setBlendMode('SansAlarm', 'add')	-- Yes x2
	
	setPropertyLuaSprite('SansAlarm', 'x', getProperty("boyfriend.x") - 225)
	setPropertyLuaSprite('SansAlarm', 'y', getProperty("boyfriend.y") - 75)
	setPropertyLuaSprite('SansAlarm', 'alpha', 0.0001)
	
	
	addLuaSprite('SansAlarm', true);
end

local dodged = false;
local attacking = false;
local attackTime = 0;
local isBlue = false;
local isFake = false;

function alarmAnim(name, reversed)
	lol = "Orange"
	if isBlue then
		lol = "Blue"
	end
	playAnim('SansAlarm', name..lol, true, reversed)
end

function onEvent(name, value1, value2)

	if name == "SansDodgeNM" then
	
		if string.lower(value2) ~= "fake" then
			attackTime = 120 / bpm
		else
			isFake = true
			attackTime = 240 / bpm
		end
		isBlue = not isBlue
		
		playSound('notice', 0.6)
		
		dodged = getProperty("cpuControlled") and not isBlue and not isFake
		
		attacking = true
		setPropertyLuaSprite('SansAlarm', 'alpha', 1)
		alarmAnim('play', false)
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
	
	dodged = true
end

function onUpdate(elapsed)
	if attacking == true then
		if attackTime > 0 then
			if not isFake then
				cameraSetTarget("bf")
			end
			if (keyboardJustPressed("SPACE") and dodged == false and not isFake) and not getProperty("cpuControlled") then
				dodge()
			end
			attackTime = attackTime - elapsed
			if attackTime <= 0 then
				if isFake then
					alarmAnim('play', true)
				else
					playSound('sansattack', 0.6)
					if dodged == true then
						
						characterPlayAnim("bf", "dodge", true)
						setProperty("boyfriend.specialAnim", true)
						setProperty("boyfriend.specialAnimExtra", true)
						
						if isBlue then 
							addHealth(-1.5) 
						end
					else
						if not isBlue then 
							addHealth(-1.5) -- 	75%  Of Full Health... YAY!
						end
					end
					alarmAnim('die', false)
				end
				if mustHitSection == false then 
					cameraSetTarget("dad")
				end
			end
		elseif getPropertyLuaSprite("SansAlarm", "animation.curAnim.finished") then
			attacking = false
			dodged = false
			if isFake then
				isBlue = not isBlue
			end
			isFake = false
			setPropertyLuaSprite('SansAlarm', 'alpha', 0.0001)
		end
	end
end
