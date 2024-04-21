package;

import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.FlxCamera;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxBasic;

class MusicBeatState extends FlxUIState
{
	public static var instance:MusicBeatState;
	public static var secondMusic:FlxSound;
	public static var secondMusicTween:Float = 1;

	public static var lastMusic:String = "";
	public static var curMusic:String = "";

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public var camExtra:FlxCamera;
	public var serverInfo:FlxText;
	public var serverInfoBG:FlxSprite;
	public var serverInfoUpdateTimer:Float;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public function handleMsg(msg:Map<String, Dynamic>){

	}
	public function updateSendMsgs(){

	}

	public function changeMusic(newMusic:String) {
		if (newMusic == curMusic) return;
		
		if (newMusic == lastMusic && secondMusic != null){
			var savedMusicTime = secondMusic.time;
			secondMusic.loadEmbedded(Paths.music(curMusic), false);
			secondMusic.volume = 1;
			secondMusic.persist = true;
			secondMusic.play();
			secondMusic.time = FlxG.sound.music.time;
			
			FlxG.sound.playMusic(Paths.music(newMusic), 0);
			FlxG.sound.music.time = savedMusicTime;
		}
		else{
			secondMusic = FlxG.sound.music;
			FlxG.sound.playMusic(Paths.music(newMusic), 0);
		}
		secondMusic.looped = false;
		secondMusic.onComplete = () -> {
			secondMusic = null;
		};
		FlxG.sound.music.looped = true;
		FlxG.sound.music.onComplete = null;
		secondMusicTween = 0;

		lastMusic = curMusic;
		curMusic = newMusic;
	}
	public function checkMusic() {
		if (FlxG.sound.music == null && curMusic.length > 0){
			FlxG.sound.playMusic(Paths.music(curMusic), 1);
		}
	}

	override function create() {
		instance = this;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		camExtra = new FlxCamera();
		camExtra.bgColor.alpha = 0;
		FlxG.cameras.add(camExtra);

		
		serverInfoBG = new FlxSprite().makeGraphic(1280, 44, 0x88000000);
		serverInfoBG.visible = false;
		add(serverInfoBG);

		serverInfo = new FlxText(0, 10, 0, "", 12);
		serverInfo.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		serverInfo.scrollFactor.set();
		serverInfo.borderSize = 1.25;
		serverInfo.cameras = [camExtra];
		serverInfo.visible = false;
		add(serverInfo);

		if(!skip) {
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		checkMusic();
		if (secondMusicTween < 1){
			secondMusicTween = Math.min(secondMusicTween + elapsed, 1);
		}
		if (lastMusic.length > 0 && secondMusic != null){
			secondMusic.volume = 1 - secondMusicTween;
		}
		if (FlxG.sound.music != null && curMusic.length > 0){
			FlxG.sound.music.volume = secondMusicTween;
		}

		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(Conductor.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);

		serverInfoUpdateTimer -= elapsed;
		if (serverInfoUpdateTimer <= 0)
		{
			serverInfo.visible = Conductor.ISONLINE;
			serverInfoBG.visible = Conductor.ISONLINE;
			if (Conductor.ISONLINE)
			{
				serverInfo.text = 'Connected | ${OnlineUtil.ISHOST ? "Host" : "Client"} | Ping: ${OnlineUtil.PING}';
				if (FlxG.state is FreeplayState){
					serverInfo.x = FlxG.width / 2 - serverInfo.width / 2;
				}
				else {
					serverInfo.x = FlxG.width - serverInfo.width - 10;
				}
				serverInfoBG.width = serverInfo.width + 20;
				serverInfoBG.x = serverInfo.width - 10;
			}
			serverInfoUpdateTimer = 1;
		}
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...Conductor.SONG.notes.length)
		{
			if (Conductor.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.6, false));
			CustomFadeTransition.finishCallback = function() {
				FlxG.switchState(nextState);
			};
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(Type.createInstance(Type.getClass(FlxG.state), []));
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(Conductor.SONG != null && Conductor.SONG.notes[curSection] != null) val = Conductor.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
