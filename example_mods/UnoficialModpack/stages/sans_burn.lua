local battleX = 0.0;
local battleY = 0.0;
local battleWidth = 1516.0;
local battleHeight = 750.0;
local heartX = 0.0;
local heartY = 0.0;
local heartControls = false;
local heartTween = 0.0;
local heartSizeHalf = 39.0;


function findSlope(x0, y0, x1, y1)
	return (y1 - y0) / (x1 - x0)
end

local bc = -2;
local blasters = {};

function onOnlineMessage(id, data)
	if id == "bf_attack" then
		attack()
	elseif id == "sans_blaster" then
		blaster(data, false)
	elseif id == "bf_heartX" then
		heartX = data
	elseif id == "bf_heartY" then
		heartY = data
	end
end

function onOnlineUpdate()
	if isPlayer then
		sendOnline("bf_heartX", heartX)
		sendOnline("bf_heartY", heartY)
	end
end

function blaster(flip, start)
	if (not isPlayer and isOnline) and not start then
		sendOnline("sans_blaster", flip)
	end
	
	bc = bc + 1
	
	name = "blaster_"..bc
	
	makeAnimatedLuaSprite(name, "Gaster_blasterss", battleX - 2450, heartY - 150 - heartSizeHalf)
	addAnimationByPrefix(name, "boom", 'fefe instance 1', 27, false);
	playAnim(name, 'boom', true)
	setPropertyLuaSprite(name, "flipX", flip)
	
	homo = 180 / math.pi * (math.atan(findSlope(getPropertyLuaSprite(name, "x"), getPropertyLuaSprite(name, "y"), heartX, heartY)));
	setPropertyLuaSprite(name, "angle", homo)
	setPropertyLuaSprite(name, "y", getPropertyLuaSprite(name, "y") + homo * 2)
	setPropertyLuaSprite(name, "height", getPropertyLuaSprite(name, "height") * 0.8)
	
	if bc >= 0 then
		runTimer(name, 1.037037)
		runTimer("shoot_"..name, 1.5925)
		playSound('readygas')
	else
		setPropertyLuaSprite(name, "alpha", 0.0001)
	end
	
	addLuaSprite(name, true);
end

local chromVal = 0.0;

function setChrome(value)
	setShaderFloat("chromatic", "rOffset", value)
	setShaderFloat("chromatic", "gOffset", 0)
	setShaderFloat("chromatic", "bOffset", -value)
end

function onCreate()
	makeLuaSprite('hall', 'stages/halldark');
	setScrollFactor('hall', 1, 1);
	scaleObject('hall', 1.5, 1.5);
	addLuaSprite('hall', false);
	screenCenter('hall')
	setPropertyLuaSprite('hall', "x", getPropertyLuaSprite('hall', "x") - 300)
	
	
	makeLuaSprite('battle', 'stages/battleUI/battle', -600, -200);
	setScrollFactor('battle', 1, 1);
	addLuaSprite('battle', false);
	setPropertyLuaSprite('battle', "alpha", 0.0001)
	
	
	makeLuaSprite('battleBG', 'stages/battleUI/bg', -600, 0);
	setScrollFactor('battleBG', 1, 1);
	addLuaSprite('battleBG', false);
	setPropertyLuaSprite('battleBG', "alpha", 0.0001)
	setGraphicSize("battleBG", getPropertyLuaSprite('battle', "width"))
	
	makeLuaSprite('heart', 'stages/battleUI/heart');
	setScrollFactor('heart', 1, 1);
	addLuaSprite('heart', true);
	setPropertyLuaSprite('heart', "alpha", 0.0001)
	setPropertyLuaSprite('heart', "antialiasing", false)
	setGraphicSize("heart", heartSizeHalf * 2.0)
	
	battleX = getPropertyLuaSprite('battle', "x") + 220
	battleY = getPropertyLuaSprite('battle', "y") + 1239
	
	heartX = battleX + battleWidth / 2
	heartY = battleY + battleHeight / 2
	
	initLuaShader("chromatic", "chromatic")
	addCameraShader("hud", "chromatic")
	addCameraShader("game", "chromatic")
	setChrome(0)
	chromVal = 0
	
	addHaxeLibrary("FlxAngle", "flixel.math")
	addHaxeLibrary("FlxPoint", "flixel.math")
	addHaxeLibrary("FlxRect", "flixel.math")
	addHaxeLibrary("FlxMath", "flixel.math")
	addHaxeLibrary("Math")
	
	blaster(false, true)
	
	makeAnimatedLuaSprite("hud_attack", "Notmobilegameanymore", -20, 235)
	addAnimationByPrefix("hud_attack", "idle", "Attack instance 1", 24, false)
	addAnimationByIndices('hud_attack', '5', 'AttackNA instance 1', "0", 24, false)
	addAnimationByIndices('hud_attack', '4', 'AttackNA instance 1', "29", 24, false)
	addAnimationByIndices('hud_attack', '3', 'AttackNA instance 1', "59", 24, false)
	addAnimationByIndices('hud_attack', '2', 'AttackNA instance 1', "90", 24, false)
	addAnimationByIndices('hud_attack', '1', 'AttackNA instance 1', "119", 24, false)
	addAnimationByPrefix("hud_attack", "fadeBack", "Attack Click instance 1", 24, false)
	
	addOffset('hud_attack', 'idle', 0, 0)
	addOffset('hud_attack', '5', -5, 15)
	addOffset('hud_attack', '4', -5, 15)
	addOffset('hud_attack', '3', -5, 15)
	addOffset('hud_attack', '2', -5, 15)
	addOffset('hud_attack', '1', -5, 15)
	addOffset('hud_attack', 'fadeBack', -6, -4)
	
	playAnim('hud_attack', 'idle', true)
	
	scaleObject('hud_attack', 0.5, 0.5, false)
	
	
	makeAnimatedLuaSprite("hud_dodge", "Notmobilegameanymore", -20, 145 + getPropertyLuaSprite('hud_attack', "height"))
	addAnimationByPrefix("hud_dodge", "idle", "Dodge instance 1", 0, false)
	addAnimationByPrefix("hud_dodge", "fuck", "Dodge click instance 1", 24, false)
	
	addOffset('hud_dodge', 'idle', 0, 0)
	addOffset('hud_dodge', 'fuck', -5, -5)
	
	playAnim('hud_dodge', 'idle', true)
	
	scaleObject('hud_dodge', 0.5, 0.5, false)
	
	setLuaSpriteCamera('hud_attack', "camHUD")
	setLuaSpriteCamera('hud_dodge', "camHUD")
	
	
	addLuaSprite('hud_attack', true);
	addLuaSprite('hud_dodge', true);
end



local battleTrans = 0;
local endTweenDodge = 0;

function onStepHit()
	if ((curStep >= 378 and curStep < 895) or (curStep >= 1149 and curStep < 1408)) and battleTrans == 0 then
		battleTrans = 1
		
		setPropertyLuaSprite('hall', "alpha", 0.0001)
		setPropertyLuaSprite('battle', "alpha", 1)
		setPropertyLuaSprite('battleBG', "alpha", 1)
		
		runHaxeCode([[
			game.defaultCamZoom = 0.35;
			FlxG.camera.zoom = game.defaultCamZoom;
		]])
		triggerEvent("Change Character", "0", "charabattle")
		triggerEvent("Change Character", "1", "sansbattle")
	end
	if ((curStep >= 895 and curStep < 1149) or curStep >= 1408) and battleTrans == 1 then
		battleTrans = 0
		heartTween = 0
		setProperty("boyfriend.alpha", 1)
		
		setPropertyLuaSprite('hall', "alpha", 1)
		setPropertyLuaSprite('battle', "alpha", 0.0001)
		setPropertyLuaSprite('battleBG', "alpha", 0.0001)
		
		runHaxeCode([[
			game.defaultCamZoom = 0.9;
			FlxG.camera.zoom = game.defaultCamZoom;
		]])
		triggerEvent("Change Character", "0", "bfchara")
		triggerEvent("Change Character", "1", "sansScared")
	end
	
	heartControls = (curStep >= 400 and curStep < 508) or (curStep >= 662 and curStep < 762)
	
end

function attack()
	if isPlayer and isOnline then
		sendOnline("bf_attack", nil)
	end
	
	playAnim('hud_attack', 'fadeBack', true)
	setProperty('boyfriend.alpha', 1)
	setPropertyLuaSprite('BfDodge', 'alpha', 0.0001)
	
	characterPlayAnim("bf", "attack", true)
	setProperty("boyfriend.specialAnim", true)
	setProperty("boyfriend.specialAnimExtra", true)
	
	playSound('Throw'..getRandomInt(1, 3))
	
	runTimer("attackBack1", 0.375)
end

local canAttack = true;

function onUpdate(elapsed)

	if getSongPosition() + 1000 >= songLength then
		return
	end
	
	setPropertyLuaSprite('hud_attack', "alpha", 1 - battleTrans)
	setPropertyLuaSprite('hud_dodge', "alpha", 1 - battleTrans - endTweenDodge)
	
	if getPropertyLuaSprite('hud_dodge', "animation.curAnim.finished") then
		playAnim('hud_dodge', 'idle', true)
	end
	if keyboardJustPressed("SHIFT") and (isPlayer or not isOnline) and battleTrans == 0 and canAttack == true then
	
		attack()
		
		canAttack = false
		
	end
	if chromVal > 0 then
		chromVal = math.max(chromVal - elapsed * 0.01, 0)
	end
	setChrome(chromVal)
	
	if getHealth() <= 0 and not isOnline then
		return
	end
	if heartControls == true and heartTween < 1 then
		heartTween = math.min(1, heartTween + elapsed * 1.5)
	end
	if heartControls == false and heartTween > 0 then
		heartTween = math.max(0, heartTween - elapsed * 1.5)
	end
	
	if heartControls == true and (isPlayer or not isOnline) then
		if getProperty("controls.NOTE_UP") then
			heartY = math.max(heartY - 500 * elapsed, battleY + heartSizeHalf);
		end
		if getProperty("controls.NOTE_DOWN") then
			heartY = math.min(heartY + 500 * elapsed, battleY + battleHeight - heartSizeHalf);
		end
		if getProperty("controls.NOTE_LEFT") then
			heartX = math.max(heartX - 500 * elapsed, battleX + heartSizeHalf);
		end
		if getProperty("controls.NOTE_RIGHT") then
			heartX = math.min(heartX + 500 * elapsed, battleX + battleWidth - heartSizeHalf);
		end
	end
	setPropertyLuaSprite('heart', "alpha", 0.0001 + heartTween)
	setPropertyLuaSprite('heart', "x", heartX - 39)
	setPropertyLuaSprite('heart', "y", heartY - 39)

	if boyfriendName == "charabattle" then
		setProperty("boyfriend.y", 1220.7 + math.sin(getSongPosition() / 250) * 25)
		setProperty("boyfriend.alpha", 1 - heartTween * 0.8)
	end
	
	if (isPlayer or not isOnline) and not getProperty("cpuControlled") then
		for _, bn in pairs(blasters) do
			runHaxeCode([[
				function getTheRotatedBounds(degrees, me){
					var newRect = new FlxRect();
					
					degrees = degrees % 360;
					if (degrees == 0)
					{
						return newRect.set(me.x, me.y, me.width, me.height);
					}
					
					if (degrees < 0)
						degrees += 360;
					
					var radians = FlxAngle.TO_RAD * degrees;
					var cos = Math.cos(radians);
					var sin = Math.sin(radians);
					
					var left = 0;
					var top = 0;
					var right = me.width;
					var bottom = me.height;
					if (degrees < 90)
					{
						newRect.x = me.x + cos * left - sin * bottom;
						newRect.y = me.y + sin * left + cos * top;
					}
					else if (degrees < 180)
					{
						newRect.x = me.x + cos * right - sin * bottom;
						newRect.y = me.y + sin * left  + cos * bottom;
					}
					else if (degrees < 270)
					{
						newRect.x = me.x + cos * right - sin * top;
						newRect.y = me.y + sin * right + cos * bottom;
					}
					else
					{
						newRect.x = me.x + cos * left - sin * top;
						newRect.y = me.y + sin * right + cos * top;
					}
					// temp var, in case input rect is the output rect
					var newHeight = Math.abs(cos * me.height) + Math.abs(sin * me.width );
					newRect.width = Math.abs(cos * me.width ) + Math.abs(sin * me.height);
					newRect.height = newHeight;
					
					return newRect;
				}
				function isInside(me, rect)
				{
					var thing = new FlxRect(me.x, me.y, me.width, me.height);
					
					if (thing.bottom > rect.bottom || thing.top < rect.top || thing.left < rect.left || thing.right > rect.right)
						return false;
					return true;
				}
				var ball = game.getLuaObject("heart", false);
				var bull = game.getLuaObject("]]..bn..[[", false);
				
				if (ball != null && bull != null && ball.overlaps(bull)) {
					var hitboxRect = new FlxRect(bull.x, bull.y + 100, bull.width, bull.height + 12);
					var rotatedRect = getTheRotatedBounds(bull.angle, hitboxRect);
					rotatedRect.width = hitboxRect.width;
					rotatedRect.height = hitboxRect.height;
					if (isInside(ball, rotatedRect)){
						game.changeHealth(-1 / 33, true);
					}
				}
			]])
		end
	end
end

function onTimerCompleted(tag, l1, l2)
	if tag == "attackBack1" then
	
		playSound('dodge', 0.6)
		
		chromVal = 0.0075
		
		if altAnim then
			characterPlayAnim("dad", "miss-alt", true)
		else
			characterPlayAnim("dad", "miss", true)
		end
		setProperty("dad.specialAnim", true)
		setProperty("dad.specialAnimExtra", true)
	
		playAnim('hud_attack', '5', true)
		runTimer("attackBack", 1, 5)
		
		addHealth(0.2, true)
		
	elseif tag == "attackBack" then
		if l2 == 0 then
			playAnim('hud_attack', 'idle', true)
			canAttack = true
		else
			playAnim('hud_attack', ''..l2, true)
		end
		
	elseif string.find(tag, "shoot_blaster_") ~= nil then
		removeLuaSprite(string.sub(tag, 7), true)
		table.remove(blasters, 1)
	elseif string.find(tag, "blaster_") ~= nil then
		playSound('shootgas')
		triggerEvent("Screen Shake", "0.1, 0.015", "0.1, 0.005")
		table.insert(blasters, tag)
		chromVal = 0.01
		
		for i=0,4 do
			x = getPropertyFromGroup("strumLineNotes.members", i+4, "x")
			y = getPropertyFromGroup("strumLineNotes.members", i+4, "y")
			a = getPropertyFromGroup("strumLineNotes.members", i+4, "angle")
			
			randox = getRandomFloat(-30, -15)
			randoy = getRandomFloat(-30, -15)
			randoa = getRandomFloat(-45, -15)
			if getRandomBool() then
				randox = getRandomFloat(15, 30)
			end
			if getRandomBool() then
				randoy = getRandomFloat(15, 30)
			end
			if getRandomBool() then
				randoa = getRandomFloat(15, 45)
			end
			x = x + randox
			y = y + randoy
			a = a + randoa
			setPropertyFromGroup("strumLineNotes.members", i+4, "x", x)
			setPropertyFromGroup("strumLineNotes.members", i+4, "y", y)
			setPropertyFromGroup("strumLineNotes.members", i+4, "angle", a)
			
			lol = "defaultPlayerStrum"
			if not isPlayer then
				lol = "defaultOpponentStrum"
			end
			
			noteTweenX("x"..i, i+4, _G[lol.."X"..i], 0.4, "cubeOut")
			noteTweenY("y"..i, i+4, _G[lol.."Y"..i], 0.4, "cubeOut")
			noteTweenAngle("a"..i, i+4, 0, 0.4, "cubeOut")
		end
	end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'SansBlaster' and (not isPlayer or not isOnline) then
		blaster(getRandomBool(), false)
	end
end

--[[
var baseX:Float = i.x;
var baseY:Float = i.y;
var baseA:Float = i.angle;
var randox = if (FlxG.random.bool()) FlxG.random.float(-30, -15); else FlxG.random.float(30, 15);
var randoy = if (FlxG.random.bool()) FlxG.random.float(-30, -15); else FlxG.random.float(30, 15);
var randoa = if (FlxG.random.bool()) FlxG.random.float(-45, -15); else FlxG.random.float(45, 15);
i.x += randox;
i.y += randoy;
i.angle += randoa;
FlxTween.tween(i, {x: baseX, y: baseY, angle: baseA}, 0.4, {
	ease: FlxEase.cubeOut,
	onComplete: function(twn:FlxTween)
	{
		i.x = baseX;
		i.y = baseY;
		i.angle = baseA;
	}
});
]]

--[[
function blastem(killme:Float)
{
	/*FlxTween.num(songSpeed, 0.95, 0.25, {}, function(v:Float)
		{
			songSpeed = v;
	});*/

	var pointAt:Vector2 = new Vector2(ball.x, ball.y);

	FlxG.sound.play(Paths.sound('readygas', 'sans'));

	var gay:FlxSprite = new FlxSprite(battle.x - 2450, ball.y - 150);
	gay.frames = Paths.getSparrowAtlas("Gaster_blasterss", "sans");
	gay.animation.addByPrefix('boom', 'fefe instance 1', 27, false);
	gay.animation.play('boom');
	gay.antialiasing = FlxG.save.data.highquality;
	gay.flipX = FlxG.random.bool();
	blaster.add(gay);
	gay.alpha = 0.999999;

	gay.height = gay.height * 0.8;

	var homo = 180 / Math.PI * (Math.atan(findSlope(gay.x, gay.y, pointAt.x, pointAt.y)));
	gay.angle = homo;
	gay.y += homo * 2;

	gay.animation.callback = function(boom, frameNumber:Int, frameIndex:Int)
	{
		if (frameNumber == 28)
		{
			gay.alpha = 1;
			/*FlxTween.num(songSpeed, 1, 0.5, {}, function(v:Float)
				{
					songSpeed = v;
			});*/ // nvmmmmmmmmmmmmmmmmmmmmmmmm
			FlxG.sound.play(Paths.sound('shootgas', 'sans'));
			FlxG.camera.shake(0.015, 0.1);
			camHUD.shake(0.005, 0.1);

			chromVal = 0.01;
			FlxTween.tween(this, {chromVal: defaultChromVal}, FlxG.random.float(0.05, 0.12));

			for (i in playerStrums)
			{
				if (i.angle == 0)
				{
					var baseX:Float = i.x;
					var baseY:Float = i.y;
					var baseA:Float = i.angle;
					var randox = if (FlxG.random.bool()) FlxG.random.float(-30, -15); else FlxG.random.float(30, 15);
					var randoy = if (FlxG.random.bool()) FlxG.random.float(-30, -15); else FlxG.random.float(30, 15);
					var randoa = if (FlxG.random.bool()) FlxG.random.float(-45, -15); else FlxG.random.float(45, 15);
					i.x += randox;
					i.y += randoy;
					i.angle += randoa;
					FlxTween.tween(i, {x: baseX, y: baseY, angle: baseA}, 0.4, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							i.x = baseX;
							i.y = baseY;
							i.angle = baseA;
						}
					});
				}
			}
		}
	}
	gay.animation.finishCallback = function(boom)
	{
		gay.kill();
	}
}
]]