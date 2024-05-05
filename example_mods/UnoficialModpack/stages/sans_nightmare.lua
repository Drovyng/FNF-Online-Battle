--[[

var beatDropbg:FlxSprite = new FlxSprite(-100, 300);
var bg:FlxSprite = new FlxSprite(-600, -160);

bg.frames = Paths.getSparrowAtlas('Nightmare Sans Stage', 'sans');
bg.animation.addByIndices('normal', 'Normal instance 1', [0], '', 24, false);
bg.animation.addByPrefix('beatdrop', 'Normal instance 1', 24, true);
bg.animation.addByPrefix('beatDropFinish', 'sdfs instance 1', 24, false);
bg.animation.play('normal');
bg.scrollFactor.set(1, 1);
bg.antialiasing = FlxG.save.data.highquality;

add(bg);

beatDropbg.frames = Paths.getSparrowAtlas('Nightmare Sans Stage', 'sans');
beatDropbg.animation.addByPrefix('beatHit', 'dd instance 1', 32, false);
beatDropbg.scrollFactor.set(0, 0);
beatDropbg.blend = BlendMode.ADD;
beatDropbg.antialiasing = FlxG.save.data.highquality;
beatDropbg.alpha = 0;

]]

local chromVal = 0.0;
local multiply = 1.0;

function setChrome(value)
	setShaderFloat("chromatic", "rOffset", value)
	setShaderFloat("chromatic", "gOffset", 0)
	setShaderFloat("chromatic", "bOffset", -value)
end

function onCreate()

	makeAnimatedLuaSprite('bg', 'stages/Nightmare Sans Stage', -600, -160);
	addAnimationByIndices('bg', 'normal', 'Normal instance 1', "0", 24, false);
	addAnimationByPrefix('bg', 'beatdrop', 'Normal instance 1', 24, true);
	addAnimationByPrefix('bg', 'beatDropFinish', 'sdfs instance 1', 24, false);
	
	playAnim('bg', 'normal', true)
	
	addLuaSprite('bg', false);
	
	
	makeAnimatedLuaSprite('beatDropbg', 'stages/Nightmare Sans Stage', -100, 300);
	addAnimationByPrefix('beatDropbg', 'beatHit', 'dd instance 1', 32, false);
	
	setBlendMode('beatDropbg', 'add')	-- Yes
	
	setPropertyLuaSprite('beatDropbg', 'alpha', 0)
	setScrollFactor('beatDropbg', 0, 0);
	
	addLuaSprite('beatDropbg', true);
	
	
	initLuaShader("chromatic", "chromatic")
	--addCameraShader("hud", "chromatic")		NO!
	addCameraShader("game", "chromatic")
	setChrome(0)
	chromVal = 0
	
	if difficultyName ~= "hard" then
		multiply = 1.5
	end
	
	nightmareSansBGManager('normal');
end

function onUpdate(elapsed)

	if getSongPosition() + 1000 >= songLength then
		return
	end

	if chromVal > 0 then
		chromVal = math.max(chromVal - elapsed * 0.075, 0)
	end
	setChrome(chromVal)

end

function nightmareSansBGManager(anim)
	if anim == 'beatDropFinish' then
		setPropertyLuaSprite('beatDropbg', 'alpha', 1)
	else
		setPropertyLuaSprite('beatDropbg', 'alpha', 0)
	end
	playAnim('bg', anim, true)
end

function onBeatHit()
	if curBeat % 2 == 0 then
		playAnim('beatDropbg', 'beatHit', true)
	end
end

function onStepHit()

	if curStep == 384 or curStep == 768 or curStep == 1184 then
	
		nightmareSansBGManager('beatdrop');
		
	elseif curStep == 512 or curStep == 928 or curStep == 1440 then
	
		nightmareSansBGManager('beatDropFinish');
	
	end
end

function opponentNoteHit()
	shakeMulty = (multiply - 1) * 0.5 + 1
	triggerEvent("Screen Shake", "0.1, "..(0.015 * shakeMulty), "0.1, "..(0.005 * shakeMulty))
	chromVal = getRandomFloat(0.005, 0.01) * multiply
end