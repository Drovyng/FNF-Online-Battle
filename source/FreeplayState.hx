package;

import flixel.addons.ui.FlxUIButton;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.tweens.FlxEase;
import OnlineUtil.OnlineUtilDataIDs;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.sound.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	public static var curSelected:Int = 0;
	public var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var modLogo:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	public var onlineP1Seleced:Int = -1;
	public var onlineP2Seleced:Int = -1;
	public var onlinePlayer:FlxText;
	public var onlinePlayerBG:FlxSprite;

	public var curSelectedConfirm:Bool = false;

	override function create()
	{
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), leWeek.modPrefix);
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
				//songText.updateHitbox();
				//trace(songs[i].songName + ' new scale: ' + textScale);
			}

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		leftSelector = new Alphabet(0, 0, ">>>>>>>>>>>>", true);
		rightSelector = new Alphabet(0, 0, "<<<<<<<<<<<<", true);

		leftSelector.isMenuItem = true;
		rightSelector.isMenuItem = true;

		leftSelector.x = -leftSelector.width;
		rightSelector.x = FlxG.width;

		add(leftSelector);
		add(rightSelector);

		super.create();

		if (Conductor.ISONLINE){
			onlinePlayerBG = new FlxSprite(0, serverInfoBG.height).makeGraphic(256, 72, 0xFF000000);
			onlinePlayerBG.alpha = 0.6;

			onlinePlayerBG.visible = Conductor.ISONLINE && OnlineUtil.ISHOST;
			add(onlinePlayerBG);

			onlinePlayer = new FlxText(10, onlinePlayerBG.y + 30, 0, "", 32);
			onlinePlayer.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
			onlinePlayer.text = "Is Player:\nTrue";
			onlinePlayerBG.width = onlinePlayer.width + 20;
			onlinePlayerBG.height = 72;

			onlinePlayer.visible = Conductor.ISONLINE && OnlineUtil.ISHOST;
			add(onlinePlayer);


			chatBG = new FlxSprite(FlxG.width - 350, FlxG.height - 326).makeGraphic(350, 400, FlxColor.BLACK);
			chatBG.alpha = 0.15;
			chatText = new FlxText(FlxG.width - 345, FlxG.height - 50, 340, "", 18);
			chatText.alpha = 0.25;

			chatInput = new FlxUIInputText(FlxG.width - 350, FlxG.height - 50, 300, "", 18, FlxColor.WHITE, FlxColor.BLACK, true);
			
			chatInput.alpha = 0.5;

			chatButton = new FlxUIButton(FlxG.width - 50, FlxG.height - 50, "Send", () -> {
				if (chatInput.text.length > 0 && chatInput.text != chatInputFiller){
					chatText.text += "<You> " + chatInput.text + "\n";
					OnlineUtil.AddData([
						"id" => OnlineUtilDataIDs.ChatMessage,
						"text" => "<Opponent> " + chatInput.text + "\n"
					]);
					chatText.text = "";
				}
			}, true, false, FlxColor.BLACK);

			chatButton.label.color = FlxColor.WHITE;
			chatButton.label.size = 18;
			chatButton.setSize(50, 26);
			chatButton.alpha = 0.5;
			chatAlpha = 0;
		}
	}

	override function handleMsg(msg:Map<String, Dynamic>) {
		super.handleMsg(msg);
		if (msg["id"] == OnlineUtilDataIDs.ChatMessage){
			chatText.text += msg["text"];
			chatAlpha = 1;
		}
	}

	var leftSelector:Alphabet;
	var rightSelector:Alphabet;
	var chatBG:FlxSprite;
	var chatText:FlxText;
	var chatAlpha:Float;
	var chatInput:FlxUIInputText;
	var chatInputFiller:String = "Chat Message...";
	var chatButton:FlxUIButton;

	public function updateModLogo(){
		if (members.contains(modLogo))
			remove(modLogo);

		var prefix = songs[curSelected].modPrefix;

		if (prefix.length > 0){
			prefix = prefix + "_";
		}

		modLogo = new FlxSprite(0, 0);
		modLogo.frames = Paths.getSparrowAtlas(prefix + 'logoBumpin');

		modLogo.antialiasing = ClientPrefs.globalAntialiasing;
		modLogo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		modLogo.animation.play('bump');
		modLogo.scale.set(0.35, 0.35);
		modLogo.updateHitbox();

		modLogo.y = 0;
		modLogo.screenCenter(X);
		
		add(modLogo);
	}

	override function beatHit() {
		super.beatHit();
		modLogo.animation.play('bump', true);
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, modPrefix:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, modPrefix));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	var hasInput:Bool = true;
	override function update(elapsed:Float)
	{
		if (Conductor.ISONLINE)
		{
			hasInput = !chatInput.hasFocus;

			if (FlxG.mouse.overlaps(chatBG) || !hasInput){
				if (chatAlpha < 1) 
				{
					chatAlpha = Math.min(chatAlpha, chatAlpha + elapsed);
				}
			}
			else if (chatAlpha > 0) 
			{
				chatAlpha = Math.max(chatAlpha, chatAlpha - elapsed);
			}
			chatBG.alpha = 0.15 + chatAlpha * 0.35;
			chatText.y = FlxG.height - 50 - chatText.height;
			chatText.alpha = 0.25 + chatAlpha * 0.65;
			chatInput.alpha = 0.5 + chatAlpha * 0.25;
			chatButton.alpha = 0.5 + chatAlpha * 0.25;

			if (!hasInput){
				if (chatInput.text == chatInputFiller){
					chatInput.text = "";
				}
			}
			else if (chatInput.text == ""){
				chatInput.text = chatInputFiller;
			}
		}

		Conductor.songPosition = FlxG.sound.music.time;
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (curSelectedConfirm)
		{
			var halfWidth = (grpSongs.members[curSelected].width + 150) / 2;

			leftSelector.forceX = FlxG.width / 2 - halfWidth - leftSelector.width - 125;
			rightSelector.forceX = FlxG.width / 2 + halfWidth + 125;
		}
		else
		{
			leftSelector.forceX = -leftSelector.width;
			rightSelector.forceX = FlxG.width;
		}


		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P && hasInput;
		var downP = controls.UI_DOWN_P && hasInput;
		var accepted = controls.ACCEPT && hasInput;
		var space = FlxG.keys.justPressed.SPACE && hasInput;
		var ctrl = FlxG.keys.justPressed.CONTROL && hasInput;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP && !curSelectedConfirm)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP && !curSelectedConfirm)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if((controls.UI_DOWN || controls.UI_UP) && !curSelectedConfirm)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0 && !curSelectedConfirm && hasInput)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK && hasInput)
		{
			if (curSelectedConfirm){
				FlxG.sound.play(Paths.sound('cancelMenu'));
				curSelectedConfirm = false;
				grpSongs.members[curSelected].forceX = Math.NEGATIVE_INFINITY;
			}
			else if (!Conductor.ISONLINE){
				persistentUpdate = false;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if(ctrl)
		{
			if (!Conductor.ISONLINE){
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if (OnlineUtil.ISHOST){
				Conductor.ISPLAYER = !Conductor.ISPLAYER;
				
				onlinePlayer.text = "Is Player:\n" + (Conductor.ISPLAYER ? "YES" : "NO");
				onlinePlayerBG.width = onlinePlayer.width + 20;
				onlinePlayerBG.height = 72;
			}
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				Conductor.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (Conductor.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(Conductor.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(Conductor.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			if (Conductor.ISONLINE){
				
				if (!curSelectedConfirm)
				{
					if (curSelected == onlineP1Seleced || curSelected == onlineP2Seleced)
					{
						if (OnlineUtil.ISHOST) selectionConfirm();
					}
					else
					{
						onlineP1Seleced = curSelected;
						OnlineUtil.AddData([
							"id" => OnlineUtilDataIDs.SelectSong,
							"value1" => onlineP1Seleced
						]);
						updateOnlineSelection();
					}
				}
				else
				{
					OnlineUtil.AddData([
						"id" => OnlineUtilDataIDs.GoToSong,
						"value1" => curSelected,
						"value2" => curDifficulty,
						"value3" => !Conductor.ISPLAYER
					]);
					startSong();
				}
			}
			else{
				if (!curSelectedConfirm)
				{
					selectionConfirm();
				}
				else
				{
					Conductor.ISPLAYER = true;
					startSong();
				}
			}
		}
		else if(controls.RESET && hasInput)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public function selectionConfirm(){
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelectedConfirm = true;
		grpSongs.members[curSelected].forceX = FlxG.width / 2 - (grpSongs.members[curSelected].width + 145) / 2;
	}

	public function updateOnlineSelection(){
		for (item in grpSongs.members)
		{
			item.color = 0xFFFFFFFF;
		}
		if (onlineP1Seleced != -1) grpSongs.members[onlineP1Seleced].color = 0xFF55FFAA;
		if (onlineP2Seleced != -1) grpSongs.members[onlineP2Seleced].color = 0xFFFFAA55;
	}

	public function startSong(){
		//PlayState.timeStartCountdown = -1;
		Conductor.P1Loaded = false;
		Conductor.P2Loaded = false;

		persistentUpdate = false;
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
		trace(poop);

		Conductor.SONG = Song.loadFromJson(poop, songLowercase);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;

		trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
		if(colorTween != null) {
			colorTween.cancel();
		}
		
		if (FlxG.keys.pressed.SHIFT && !Conductor.ISONLINE){
			LoadingState.loadAndSwitchState(new ChartingState());
		}else{
			LoadingState.loadAndSwitchState(new PlayState());
		}

		FlxG.sound.music.volume = 0;
				
		destroyFreeplayVocals();
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	public function changeDiff(change:Int = 0)
	{
		if (curSelectedConfirm) return;
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	public function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (curSelectedConfirm) return;
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var modPrefix = songs[curSelected].modPrefix;

		if (modPrefix.length > 0){
			modPrefix = modPrefix + "_";
		}
		if (vocals != null){
			vocals.stop();
			vocals = null;
		}
		changeMusic(modPrefix + "freakyMenu");
		
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		updateModLogo();
	}



	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var modPrefix:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, modPrefix:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		this.modPrefix = modPrefix;
		if(this.folder == null) this.folder = '';
	}
}