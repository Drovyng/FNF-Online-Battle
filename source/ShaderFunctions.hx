package;

import openfl.filters.ShaderFilter;
import llua.Lua.Lua_helper;
import flixel.util.FlxColor;
#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

class ShaderFunctions
{
	public static function implement(funk:FunkinLua)
	{
		// shader shit
		funk.addLocalCallback("initLuaShader", function(name:String, file:String, ?glslVersion:Int = 120) {
			//if(!ClientPrefs.data.shaders) return false;

			#if (!flash && MODS_ALLOWED && sys)
			return funk.initLuaShader(name, file, glslVersion);
			#else
			FunkinLua.luaTrace("initLuaShader: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			#end
			return false;
		});
		
		funk.addLocalCallback("addCameraShader", function(cam:String, shader:String){
			#if (!flash && MODS_ALLOWED && sys)
			if(!FunkinLua.runtimeShaders.exists(shader))
			{
				FunkinLua.luaTrace('addCameraShader: Shader $shader is missing!', FlxColor.RED);
				return false;
			}

			var camera = funk.cameraFromString(cam);
			camera.filtersEnabled = true;
			if (camera.filters == null){
				camera.filters = [];
			}

			camera.filters.push(new ShaderFilter(FunkinLua.runtimeShaders[shader]));
			
			#else
			FunkinLua.luaTrace("setSpriteShader: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			#end
			return false;
		});

		funk.addLocalCallback("setSpriteShader", function(obj:String, shader:String) {
			//if(!ClientPrefs.data.shaders) return false;

			#if (!flash && MODS_ALLOWED && sys)
			if(!FunkinLua.runtimeShaders.exists(shader))
			{
				FunkinLua.luaTrace('setSpriteShader: Shader $shader is missing!', FlxColor.RED);
				return false;
			}

			var leObj = PlayState.instance.getLuaObject(obj);
			if(leObj != null) {
				leObj.shader = FunkinLua.runtimeShaders[shader];
				return true;
			}
			#else
			FunkinLua.luaTrace("setSpriteShader: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			#end
			return false;
		});
		funk.addLocalCallback("removeSpriteShader", function(obj:String) {
			var leObj = PlayState.instance.getLuaObject(obj);

			if(leObj != null) {
				leObj.shader = null;
				return true;
			}
			return false;
		});


		funk.addLocalCallback("getShaderBool", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			return FunkinLua.runtimeShaders[obj].getBool(prop);
			#else
			FunkinLua.luaTrace("getShaderBool: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		funk.addLocalCallback("getShaderBoolArray", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			return FunkinLua.runtimeShaders[obj].getBoolArray(prop);
			#else
			FunkinLua.luaTrace("getShaderBoolArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		funk.addLocalCallback("getShaderInt", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			return FunkinLua.runtimeShaders[obj].getInt(prop);
			#else
			FunkinLua.luaTrace("getShaderInt: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		funk.addLocalCallback("getShaderIntArray", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			return FunkinLua.runtimeShaders[obj].getIntArray(prop);
			#else
			FunkinLua.luaTrace("getShaderIntArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		funk.addLocalCallback("getShaderFloat", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			return FunkinLua.runtimeShaders[obj].getFloat(prop);
			#else
			FunkinLua.luaTrace("getShaderFloat: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		funk.addLocalCallback("getShaderFloatArray", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			return FunkinLua.runtimeShaders[obj].getFloatArray(prop);
			#else
			FunkinLua.luaTrace("getShaderFloatArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});


		funk.addLocalCallback("setShaderBool", function(obj:String, prop:String, value:Bool) {
			#if (!flash && MODS_ALLOWED && sys)
			FunkinLua.runtimeShaders[obj].setBool(prop, value);
			return true;
			#else
			FunkinLua.luaTrace("setShaderBool: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		funk.addLocalCallback("setShaderBoolArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && MODS_ALLOWED && sys)
			FunkinLua.runtimeShaders[obj].setBoolArray(prop, values);
			return true;
			#else
			FunkinLua.luaTrace("setShaderBoolArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		funk.addLocalCallback("setShaderInt", function(obj:String, prop:String, value:Int) {
			#if (!flash && MODS_ALLOWED && sys)
			FunkinLua.runtimeShaders[obj].setInt(prop, value);
			return true;
			#else
			FunkinLua.luaTrace("setShaderInt: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		funk.addLocalCallback("setShaderIntArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && MODS_ALLOWED && sys)
			FunkinLua.runtimeShaders[obj].setIntArray(prop, values);
			return true;
			#else
			FunkinLua.luaTrace("setShaderIntArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		funk.addLocalCallback("setShaderFloat", function(obj:String, prop:String, value:Float) {
			#if (!flash && MODS_ALLOWED && sys)
			FunkinLua.runtimeShaders[obj].setFloat(prop, value);
			return true;
			#else
			FunkinLua.luaTrace("setShaderFloat: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		funk.addLocalCallback("setShaderFloatArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && MODS_ALLOWED && sys)
			FunkinLua.runtimeShaders[obj].setFloatArray(prop, values);
			return true;
			#else
			FunkinLua.luaTrace("setShaderFloatArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return true;
			#end
		});

		funk.addLocalCallback("setShaderSampler2D", function(obj:String, prop:String, bitmapdataPath:String) {
			#if (!flash && MODS_ALLOWED && sys)
			// trace('bitmapdatapath: $bitmapdataPath');
			var value = Paths.image(bitmapdataPath);
			if(value != null && value.bitmap != null)
			{
				// trace('Found bitmapdata. Width: ${value.bitmap.width} Height: ${value.bitmap.height}');
				FunkinLua.runtimeShaders[obj].setSampler2D(prop, value.bitmap);
				return true;
			}
			return false;
			#else
			FunkinLua.luaTrace("setShaderSampler2D: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
	}
}