package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	public var animated:Bool = false;

	public var lastState:Bool = true;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	public function changeIcon(char:String) {
		if(this.char != char) {
			animated = char.charAt(0).toUpperCase() == char.charAt(0);
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			
			if (animated){
				frames = Paths.getSparrowAtlas(name);
				animation.addByPrefix("idle", "ICON " + char.toUpperCase(), 24);
				animation.addByPrefix("low", char.toUpperCase() + " ICON ", 24);
				animation.play("idle", true);
			}
			else{
				var file:Dynamic = Paths.image(name);
				loadGraphic(file, true, 150, 150);
	
				animation.add("idle", [0], 0, false, isPlayer);
				animation.add("low", [1], 0, false, isPlayer);
				animation.play("idle", true);
			}
			updateHitbox();
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	public function setState(idle:Bool) {
		if (idle != lastState){
			lastState = idle;
			updateHitbox();
			animation.play(idle ? "idle" : "low", true);
		}
	}

	public function getCharacter():String {
		return char;
	}
}
