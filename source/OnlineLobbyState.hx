package;

import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxSpriteGroup;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class OnlineLobbyState extends MusicBeatState
{
	public var bg:FlxSprite;
	public var logo:FlxSprite;
	public var logoRotation:Float;

	public var hasControls:Bool = true;
	public var hasControlsInput:Bool = true;
	public var selecterJoin:Bool;
	public var hostButton:FlxSprite;
	public var joinButton:FlxSprite;

	public var hue:Float = 0;
	public var light:Float = 0.6;

	public var input_ip:FlxUIInputText;
	public var input_port:FlxUIInputText;

	override function create()
	{
		super.create();


		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

		// 1280 + 224 pixels
		bg.setGraphicSize(Std.int(bg.width * 1.2));

		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		logo = new FlxSprite();
		logo.frames = Paths.getSparrowAtlas('mainmenu/menu_multiplayer');
		logo.animation.addByPrefix('idle', "multiplayer white", 24, true);
		logo.animation.play('idle');
		logo.scale.set(0.8, 0.8);
		logo.updateHitbox();

		logo.offset.set(logo.width / 2, logo.height / 2);
		
		logo.screenCenter(X);
		logo.y = FlxG.height * 0.15 - logo.height / 2;
		
		add(logo);

		hostButton = new FlxSprite();
		hostButton.frames = Paths.getSparrowAtlas('mainmenu/multiplayer/host');
		hostButton.animation.addByPrefix('idle', "host basic", 24, true);
		hostButton.animation.addByPrefix('selected', "host white", 24, true);
		hostButton.animation.play('selected');
		hostButton.updateHitbox();
		
		add(hostButton);
		
		
		joinButton = new FlxSprite();
		joinButton.frames = Paths.getSparrowAtlas('mainmenu/multiplayer/join');
		joinButton.animation.addByPrefix('idle', "join basic", 24, true);
		joinButton.animation.addByPrefix('selected', "join white", 24, true);
		joinButton.animation.play('idle');
		joinButton.updateHitbox();
		
		add(joinButton);

		input_ip = new FlxUIInputText(0, FlxG.height * 0.9 - 8, 200, "localhost", 16);
		input_port = new FlxUIInputText(0, FlxG.height * 0.9 - 8, 100, "8097", 16);
		
		input_ip.x = FlxG.width / 2 - (input_ip.width + 25 + input_port.width) / 2;
		input_port.x = input_ip.x + input_ip.width + 25;

		add(input_ip);
		add(input_port);

		check_poses();
		selecterJoin = false;

		checkMusic();
	}
	public function check_poses() 
	{
		hostButton.screenCenter(X);
		hostButton.y = FlxG.height * 0.4 - hostButton.height / 2;
		hostButton.offset.set(hostButton.width / 2, hostButton.height / 2);
		hostButton.centerOffsets();

		
		joinButton.screenCenter(X);
		joinButton.y = FlxG.height * 0.65 - joinButton.height / 2;
		joinButton.offset.set(joinButton.width / 2, joinButton.height / 2);
		joinButton.centerOffsets();
	}

	override function beatHit() {
		super.beatHit();
		if (curBeat % 2 == 0){
			light = 1;
			hue += 60;
			hue %= 360;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!hasControls){
			input_ip.hasFocus = false;
			input_port.hasFocus = false;
		}
		hasControlsInput = !(input_ip.hasFocus || input_port.hasFocus);

		checkMusic();
		Conductor.songPosition = FlxG.sound.music.time;

		if (light > 0.6){
			light = Math.max(0.6, light - elapsed * Conductor.crochet / 1000);
		}
		if (light < 0.6){
			light = Math.min(0.6, light + elapsed * Conductor.crochet / 1000);
		}

		var logoScale = 0.8 + Math.abs(light - 0.6) / 2.5;
		logo.scale.set(logoScale, logoScale);
		logo.updateHitbox();
		logo.screenCenter(X);
		logo.y = FlxG.height * 0.15 - logo.height / 2;

		bg.color = FlxColor.fromHSL(hue, 0.8, light);

		logoRotation += elapsed * (1.0 + Math.abs(light - 0.6) * 5) * 1.5;

		if (logoRotation >= Math.PI * 2){
			logoRotation -= Math.PI * 2;
		}
		logo.angle = 5 * Math.sin(logoRotation);


		if (controls.BACK && hasControls && hasControlsInput)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if (hasControls && hasControlsInput && (controls.UI_DOWN_P || controls.UI_UP_P))
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			selecterJoin = !selecterJoin;
			hostButton.animation.play(selecterJoin ? 'idle' : "selected");
			joinButton.animation.play(selecterJoin ? "selected" : 'idle');

			check_poses();
		}
		if (controls.ACCEPT && hasControls && hasControlsInput)
		{
			hasControls = false;
			light = 0;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxFlicker.flicker(selecterJoin ? joinButton : hostButton, 1, 0.06, false, false, function(_)
			{
				hasControls = true;
				
				(selecterJoin ? joinButton : hostButton).visible = true;
				var parsed:Null<Int> = Std.parseInt(input_port.text);
				if (Math.isNaN(parsed) || Math.isFinite(parsed)) parsed = null;
				OnlineUtil.StartThread(!selecterJoin, input_ip.text, parsed);
			});
		}
	}
	public function onConnected(){
		hasControls = false;
		MusicBeatState.switchState(new FreeplayState());
	}
}
