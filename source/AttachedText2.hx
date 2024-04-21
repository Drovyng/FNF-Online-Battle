package;

import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.text.FlxText;

class AttachedText2 extends FlxText {
    public var obj:FlxObject;
    public function new(_text:String, _size:Int, _obj:FlxObject) {
        super(0, 0, 0, _text, _size);
        setFormat(Paths.font("vcr.ttf"), _size, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scrollFactor.set();
		obj = _obj;
    }
    override function update(elapsed:Float) {
        if (obj != null){
            visible = obj.active && obj.alive;
            x = obj.getMidpoint().x - width / 2;
            y = obj.getMidpoint().y - height / 2;
        }
    }
}