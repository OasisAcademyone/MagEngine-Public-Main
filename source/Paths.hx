package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end

import flash.media.Sound;

using StringTools;


class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static var modsthing:Map<String, Bool> = new Map<String, Bool>();
	static public var modDir:String = null;
	public static var customSoundsLoaded:Map<String, Sound> = new Map();

	static var currentLevel:String;

	static public function getModFolders()
		{
			modsthing.set('data', true);
			modsthing.set('songs', true);
			modsthing.set('dialogues', true);
		}

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
		{
			return getPath('$key.txt', TEXT, library);
		}
	
		
		


	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}
	
	inline static public function video(key:String, ?library:String)
	{
		trace('assets/videos/$key.mp4');
		return getPath('videos/$key.mp4', BINARY, library);
	}
	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Any
		{
			var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Voices'));
			if(file != null) {
				return file;
			}
	
			return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Voices.$SOUND_EXT';
		}
	
		inline static public function inst(song:String):Any
		{
		
			var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Inst'));
			if(file != null) {
				return file;
			}
		
			return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Inst.$SOUND_EXT';
		}

	inline static private function returnSongFile(file:String):Sound
	{
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		return null;
	}

	inline static public function fileExists(key:String, type:AssetType, ?library:String)
		{
			if(FileSystem.exists(mods(modDir + '/' + key)) || FileSystem.exists(mods(key))) {
				return true;
			}
			
			if(OpenFlAssets.exists(Paths.getPath(key, type, library))) {
				return true;
			}
			return false;
		}
	
	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';

	}

	inline static public function bruhtxt(key:String)
		{
			return modfold('$key.txt');
		}

	inline static public function mods(key:String = '') {
		return 'mods/' + key;
	}

	inline static public function modsSongs(key:String) {
		return modfold('songs/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsong(key:String) {
		return modfold('data/' + key + '.json');
	}
	
	
	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
	static public function modfold(key:String) {
		if(modDir != null && modDir.length > 0) {
			// psych engine for the win
			var fileToCheck:String = mods(modDir + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}
		return 'mods/' + key;
	}
}
