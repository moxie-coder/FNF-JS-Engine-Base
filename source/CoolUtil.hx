package;

import Song.SwagSong;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import haxe.io.Bytes;
import haxe.io.Path;
import lime.app.Application;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets;
import shaders.RGBPalette.RGBShaderReference;
import utils.CoolSystemStuff;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#else
import openfl.utils.Assets;
#end

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];

	public static var defaultDifficultiesFull:Array<String> = [
		'Easy',
		'Normal',
		'Hard',
		'Erect',
		'Nightmare'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var defaultDifficultyThings:Array<String> = ['Normal', 'normal'];

	public static var difficulties:Array<String> = [];

	public static var currentDifficulty:String = 'Normal';

	public static var defaultSongs:Array<String> = ['tutorial', 'bopeebo', 'fresh', 'dad battle', 'spookeez', 'south', 'monster', 'pico', 'philly nice', 'blammed', 'satin panties', 'high', 'milf', 'cocoa', 'eggnog', 'winter horrorland', 'senpai', 'roses', 'thorns', 'ugh', 'guns', 'stress', 'darnell', 'lit up', '2hot'];
	public static var defaultSongsFormatted:Array<String> = ['dad-battle', 'philly-nice', 'satin-panties', 'winter-horrorland', 'lit-up'];

	public static var defaultCharacters:Array<String> = ['dad', 'gf', 'gf-bent', 'gf-car', 'gf-christmas', 'gf-pixel', 'gf-tankmen', 'mom', 'mom-car', 'monster', 'monster-christmas', 'parents-christmas', 'pico', 'pico-player', 'senpai', 'senpai-angry', 'spirit', 'spooky', 'tankman', 'tankman-player'];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		//trace(snap); yo why does it trace the snap
		return (m / snap);
	}

	#if desktop
	public static var resW:Float = 1;
	public static var resH:Float = 1;
	public static var baseW:Float = 1;
	public static var baseH:Float = 1;
	inline public static function resetResScale(wid:Int = 1280, height:Int = 720) {
		resW = wid/baseW;
		resH = height/baseH;
	}
	#end

	public static var getUsername = CoolSystemStuff.getUsername;
	public static var getUserPath = CoolSystemStuff.getUserPath;
	public static var getTempPath = CoolSystemStuff.getTempPath;

	public static function selfDestruct():Void //this function instantly deletes your JS Engine build. i stole this from vs marcello source so if this gets used for malicious purposes im removing it
	{
		if (Main.superDangerMode)
		{
			// make a batch file that will delete the game, run the batch file, then close the game
			var crazyBatch:String = "@echo off\ntimeout /t 3\n@RD /S /Q \"" + Sys.getCwd() + "\"\nexit";
			File.saveContent(getTempPath() + "/die.bat", crazyBatch);
			new Process(getTempPath() + "/die.bat", []);
		}
		Sys.exit(0);
	}

	public static function updateTheEngine():Void {
			// Get the directory of the executable
			var exePath = Sys.programPath();
			var exeDir = Path.directory(exePath);

			// Construct the source and destination paths
			var sourceDirectory = Path.join([exeDir, "update", "raw"]);
			var destinationDirectory = exeDir;

			var scriptContent:String;
			var scriptFileName:String;
			var appName:String = "JSEngine"; // The base name of your executable/application bundle

			#if windows
			scriptFileName = "update.bat";
			// Escape backslashes for use in the batch script
			var winSourceDir = sourceDirectory.split('\\').join('\\\\');
			var winDestDir = destinationDirectory.split('\\').join('\\\\');
			var winExeName = appName + ".exe";

			scriptContent = "@echo off\r\n";
			scriptContent += "setlocal enabledelayedexpansion\r\n";
			scriptContent += "set \"sourceDirectory=" + winSourceDir + "\"\r\n";
			scriptContent += "set \"destinationDirectory=" + winDestDir + "\"\r\n";
			scriptContent += "if not exist \"!sourceDirectory!\" (\r\n";
			scriptContent += "   echo Source directory does not exist: !sourceDirectory!\r\n";
			scriptContent += "   pause\r\n";
			scriptContent += "   exit /b\r\n";
			scriptContent += ")\r\n";
			scriptContent += "taskkill /F /IM " + winExeName + " >nul 2>&1\r\n"; // >nul 2>&1 to suppress success messages
			scriptContent += "echo Waiting for 5 seconds to ensure application is closed...\r\n";
			scriptContent += "timeout /t 5 /nobreak >nul\r\n";
			scriptContent += "echo Copying files from !sourceDirectory! to !destinationDirectory!...\r\n";
			scriptContent += "xcopy /e /y /i \"!sourceDirectory!\" \"!destinationDirectory!\"\r\n"; // /i assumes dest is dir if missing
			scriptContent += "echo Cleaning up temporary update files...\r\n";
			scriptContent += "rd /s /q \"!sourceDirectory!\" >nul 2>&1\r\n"; // Delete raw folder
			scriptContent += "rd /s /q \"%~dp0\\update\" >nul 2>&1\r\n"; // Delete parent update folder
			scriptContent += "echo Restarting application...\r\n";
			scriptContent += "start /b \"\" \"!destinationDirectory!\\" + winExeName + "\"\r\n"; // Use /b to prevent new window, empty "" for title
			scriptContent += "del \"%~f0\" >nul 2>&1\r\n"; // Delete self
			scriptContent += "endlocal\r\n";

			#elseif mac
			scriptFileName = "update.sh";
			var currentAppBundlePath = Path.directory(Path.directory(exePath));
			if (!currentAppBundlePath.endsWith(".app")) {
					 Application.current.window.alert("Could not determine application bundle path for update. Please update manually.");
					 Sys.exit(1);
			}

			var macExeName = appName; // The actual executable name inside MacOS/

			scriptContent = "#!/bin/bash\n";
			scriptContent += "set -e\n"; // Exit immediately if a command exits with a non-zero status.
			scriptContent += "source_dir=\"" + sourceDirectory + "\"\n"; // This will be like /path/to/game/update/raw
			scriptContent += "current_app_bundle_path=\"" + currentAppBundlePath + "\"\n"; // This will be like /path/to/game/JSEngine.app

			// The new .app bundle will be inside source_dir
			var newAppBundleInSource = Path.join([sourceDirectory, appName + ".app"]);
			scriptContent += "new_app_bundle_in_source=\"" + newAppBundleInSource + "\"\n";

			scriptContent += "echo \"Source directory: $source_dir\"\n";
			scriptContent += "echo \"Current app bundle path: $current_app_bundle_path\"\n";
			scriptContent += "echo \"New app bundle in source: $new_app_bundle_in_source\"\n";

			scriptContent += "if [ ! -d \"$source_dir\" ]; then\n";
			scriptContent += "  echo \"Source directory does not exist: $source_dir\"\n";
			scriptContent += "  read -p \"Press Enter to continue...\"\n"; // Keep terminal open for user to see error
			scriptContent += "  exit 1\n";
			scriptContent += "fi\n";

			scriptContent += "if [ ! -d \"$new_app_bundle_in_source\" ]; then\n";
			scriptContent += "  echo \"New application bundle not found in update source: $new_app_bundle_in_source\"\n";
			scriptContent += "  read -p \"Press Enter to continue...\"\n";
			scriptContent += "  exit 1\n";
			scriptContent += "fi\n";


			scriptContent += "echo \"Attempting to kill existing application...\"\n";
			scriptContent += "killall \"" + macExeName + "\" || true\n"; // `|| true` to prevent script from exiting if app isn't running
			scriptContent += "echo \"Waiting for 5 seconds to ensure application is closed...\"\n";
			scriptContent += "sleep 5\n";

			scriptContent += "echo \"Copying new application bundle...\"\n";
			// Remove the old app bundle first, then copy the new one.
			scriptContent += "rm -rf \"$current_app_bundle_path\"\n";
			scriptContent += "cp -R \"$new_app_bundle_in_source\" \"$current_app_bundle_path\"\n"; // Copy the new .app bundle to replace the old one

			scriptContent += "echo \"Cleaning up temporary update files...\"\n";
			scriptContent += "rm -rf \"$source_dir\"\n"; // Delete raw folder
			scriptContent += "rm -rf \"" + Path.join([exeDir, "update"]) + "\"\n"; // Delete parent update folder
			scriptContent += "echo \"Restarting application...\"\n";
			scriptContent += "open -a \"$current_app_bundle_path\"\n"; // Open the .app bundle
			scriptContent += "rm -- \"$0\"\n"; // Delete self (the update.sh script)

			#elseif linux
			scriptFileName = "update.sh";
			var linuxExeName = appName; // The actual executable name (e.g., JSEngine)

			scriptContent = "#!/bin/bash\n";
			scriptContent += "set -e\n";
			scriptContent += "source_dir=\"" + sourceDirectory + "\"\n";
			scriptContent += "destination_dir=\"" + destinationDirectory + "\"\n";
			scriptContent += "echo \"Source directory: $source_dir\"\n";
			scriptContent += "echo \"Destination directory: $destination_dir\"\n";

			scriptContent += "if [ ! -d \"$source_dir\" ]; then\n";
			scriptContent += "  echo \"Source directory does not exist: $source_dir\"\n";
			scriptContent += "  read -p \"Press Enter to continue...\"\n";
			scriptContent += "  exit 1\n";
			scriptContent += "fi\n";

			scriptContent += "echo \"Attempting to kill existing application...\"\n";
			scriptContent += "killall \"" + linuxExeName + "\" || true\n"; // `|| true` to prevent script from exiting if app isn't running
			scriptContent += "echo \"Waiting for 5 seconds to ensure application is closed...\"\n";
			scriptContent += "sleep 5\n";

			scriptContent += "echo \"Copying files...\"\n";
			scriptContent += "cp -R \"$source_dir\"/* \"$destination_dir/\"\n"; // Copy contents of raw to destination
			scriptContent += "echo \"Setting executable permissions for " + linuxExeName + "...\"\n";
			scriptContent += "chmod +x \"$destination_dir/" + linuxExeName + "\"\n"; // Ensure executable bit is set

			scriptContent += "echo \"Cleaning up temporary update files...\"\n";
			scriptContent += "rm -rf \"$source_dir\"\n"; // Delete raw folder
			scriptContent += "rm -rf \"" + Path.join([exeDir, "update"]) + "\"\n"; // Delete parent update folder
			scriptContent += "echo \"Restarting application...\"\n";
			scriptContent += "nohup \"$destination_dir/" + linuxExeName + "\" > /dev/null 2>&1 &\n"; // Run in background, detach from shell
			scriptContent += "rm -- \"$0\"\n"; // Delete self (the update.sh script)

			#else
			// Fallback for unsupported platforms or just exit
			Application.current.window.alert("Automatic update is not supported on this platform.");
			Sys.exit(0);
			return; // Exit the function early
			#end

			// Save the script file
			var scriptPath = Path.join([exeDir, scriptFileName]);
			File.saveContent(scriptPath, scriptContent);

			#if mac || linux
			// Make the script executable on Unix-like systems
			try {
					var chmodProcess = new Process("chmod", ["+x", scriptPath]);
					var chmodResult = chmodProcess.exitCode();
					if (chmodResult != 0) {
							trace("Error setting script executable permissions: " + chmodResult);
							Application.current.window.alert("Could not set update script permissions. Please run the game as administrator or manually update.");
							Sys.exit(1); // Exit with an error code
					}
			} catch (e:Dynamic) {
					trace("Exception while setting script executable permissions: " + e);
					Application.current.window.alert("An error occurred during update: " + e);
					Sys.exit(1);
			}
			#end

			// Execute the script
			new Process(scriptPath, []);
			Sys.exit(0); // Exit the current game instance
	}

	public static function checkForOBS():Bool
	{
		var fs:Bool = FlxG.fullscreen;
		if (fs)
		{
			FlxG.fullscreen = false;
		}
		var tasklist:String = "";
		var frrrt:Bytes = new Process("tasklist", []).stdout.readAll();
		tasklist = frrrt.getString(0, frrrt.length);
		if (fs)
		{
			FlxG.fullscreen = true;
		}
		return tasklist.contains("obs64.exe") || tasklist.contains("obs32.exe");
	}

	/**
	 * Can be used to check if your using a specific version of an OS (or if your using a certain OS).
	 */
	 public static function hasVersion(vers:String)
		return lime.system.System.platformLabel.toLowerCase().indexOf(vers.toLowerCase()) != -1;

	public static function getSongDuration(musicTime:Float, musicLength:Float, precision:Int = 0):String
	{
		final secondsMax:Int = Math.floor((musicLength - musicTime) / 1000); // 1 second = 1000 miliseconds
		var secs:String = '' + Math.floor(secondsMax) % 60;
		var mins:String = "" + Math.floor(secondsMax / 60)%60;
		final hour:String = '' + Math.floor(secondsMax / 3600)%24;

		if (secs.length < 2)
			secs = '0' + secs;

		var shit:String = mins + ":" + secs;
		if (hour != "0"){
			if (mins.length < 2) mins = "0"+ mins;
			shit = hour+":"+mins + ":" + secs;
		}
		if (precision > 0)
		{
			var secondsForMS:Float = ((musicLength - musicTime) / 1000) % 60;
			var seconds:Int = Std.int((secondsForMS - Std.int(secondsForMS)) * Math.pow(10, precision));
			shit += ".";
			shit += seconds;
		}
		return shit;
	}
	public static function formatTime(musicTime:Float, precision:Int = 0):String
	{
		var secs:String = '' + Math.floor(musicTime / 1000) % 60;
		var mins:String = "" + Math.floor(musicTime / 1000 / 60) % 60;
		var hour:String = '' + Math.floor((musicTime / 1000 / 3600)) % 24;
		var days:String = '' + Math.floor((musicTime / 1000 / 86400)) % 7;
		var weeks:String = '' + Math.floor((musicTime / 1000 / (86400 * 7)));

		if (secs.length < 2)
			secs = '0' + secs;

		var shit:String = mins + ":" + secs;
		if (hour != "0" && days == '0'){
			if (mins.length < 2) mins = "0"+ mins;
			shit = hour+":"+mins + ":" + secs;
		}
		if (days != "0" && weeks == '0'){
			shit = days + 'd ' + hour + 'h ' + mins + "m " + secs + 's';
		}
		if (weeks != "0"){
			shit = weeks + 'w ' + days + 'd ' + hour + 'h ' + mins + "m " + secs + 's';
		}
		if (precision > 0)
		{
			var secondsForMS:Float = (musicTime / 1000) % 60;
			var seconds:Int = Std.int((secondsForMS - Std.int(secondsForMS)) * Math.pow(10, precision));
			shit += ".";
			if (precision > 1 && Std.string(seconds).length < precision)
			{
				var zerosToAdd:Int = precision - Std.string(seconds).length;
				for (i in 0...zerosToAdd) shit += '0';
			}
			shit += seconds;
		}
		return shit;
	}

	public static function zeroFill(value:Int, digits:Int) {
		var length:Int = Std.string(value).length;
		var format:String = "";
		if(length < digits) {
			for (i in 0...(digits - length))
				format += "0";
			format += Std.string(value);
		} else format = Std.string(value);
		return format;
	}

	public static function floatToStringPrecision(n:Float, prec:Int){
		n = Math.round(n * Math.pow(10, prec));
		var str = ''+n;
		var len = str.length;
		if(len <= prec){
			while(len < prec){
				str = '0'+str;
				len++;
			}
			return '0.'+str;
		}else{
			return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
		}
	}
	public static function getHealthColors(char:Character):Array<Int>
	{
		if (char != null) return char.healthColorArray;
		else return [255,0,0];
	}

	public static final beats:Array<Int> = [4, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192,256,384,512,768,1024,1536,2048,3072,6144];

	static var foundQuant:Int = 0;
	static var theCurBPM:Float = 0;
	static var stepCrochet:Float = 0;
	static var latestBpmChangeIndex = 0;
	static var latestBpmChange = null;
	public static function checkNoteQuant(note:Note, timeToCheck:Float, ?rgbShader:RGBShaderReference)
	{
		if (ClientPrefs.noteColorStyle == 'Quant-Based' && (ClientPrefs.showNotes && ClientPrefs.enableColorShader))
		{
			theCurBPM = Conductor.bpm;
			stepCrochet = (60 / theCurBPM) * 1000;
			latestBpmChangeIndex = -1;
			latestBpmChange = null;

			for (i in 0...Conductor.bpmChangeMap.length) {
				var bpmchange = Conductor.bpmChangeMap[i];
				if (timeToCheck >= bpmchange.songTime) {
					latestBpmChangeIndex = i; // Update index of latest change
					latestBpmChange = bpmchange;
				}
			}
			if (latestBpmChangeIndex >= 0) {
				theCurBPM = latestBpmChange.bpm;
				timeToCheck -= latestBpmChange.songTime;
				stepCrochet = (60 / theCurBPM) * 1000;
			}

			var beat = Math.round((timeToCheck / stepCrochet) * 1536); //really stupid but allows the game to register every single quant
			for (i in 0...beats.length)
			{
				if (beat % (6144 / beats[i]) == 0)
				{
					beat = beats[i];
					foundQuant = i;
					break;
				}
			}

			if (rgbShader != null) {
				rgbShader.r = ClientPrefs.quantRGB[foundQuant][0];
				rgbShader.g = ClientPrefs.quantRGB[foundQuant][1];
				rgbShader.b = ClientPrefs.quantRGB[foundQuant][2];
			}
		}
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num].toLowerCase();
		if(fileSuffix != defaultDifficulty.toLowerCase())
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	public static function toCompactNumber(number:Float):String
	{
		var suffixes1:Array<String> = ['ni', 'mi', 'bi', 'tri', 'quadri', 'quinti', 'sexti', 'septi', 'octi', 'noni'];
		var tenSuffixes:Array<String> = ['', 'deci', 'viginti', 'triginti', 'quadraginti', 'quinquaginti', 'sexaginti', 'septuaginti', 'octoginti', 'nonaginti', 'centi'];
		var decSuffixes:Array<String> = ['', 'un', 'duo', 'tre', 'quattuor', 'quin', 'sex', 'septe', 'octo', 'nove'];
		var centiSuffixes:Array<String> = ['centi', 'ducenti', 'trecenti', 'quadringenti', 'quingenti', 'sescenti', 'septingenti', 'octingenti', 'nongenti'];

		var magnitude:Int = 0;
		var num:Float = number;
		var tenIndex:Int = 0;

		while (num >= 1000.0)
		{
			num /= 1000.0;

			if (magnitude == suffixes1.length - 1) {
				tenIndex++;
			}

			magnitude++;

			if (magnitude == 21) {
				tenIndex++;
				magnitude = 11;
			}
		}

		// Determine which set of suffixes to use
		var suffixSet:Array<String> = (magnitude <= suffixes1.length) ? suffixes1 : ((magnitude <= suffixes1.length + decSuffixes.length) ? decSuffixes : centiSuffixes);

		// Use the appropriate suffix based on magnitude
		var suffix:String = (magnitude <= suffixes1.length) ? suffixSet[magnitude - 1] : suffixSet[magnitude - 1 - suffixes1.length];
		var tenSuffix:String = (tenIndex <= 10) ? tenSuffixes[tenIndex] : centiSuffixes[tenIndex - 11];

		// Use the floor value for the compact representation
		var compactValue:Float = Math.floor(num * 100) / 100;

		if (compactValue <= 0.001) {
			return "0"; // Return 0 if compactValue = null
		} else {
			var illionRepresentation:String = "";

			if (magnitude > 0) {
				illionRepresentation += suffix + tenSuffix;
			}

				if (magnitude > 1) illionRepresentation += "llion";

			return compactValue + (magnitude == 0 ? "" : " ") + (magnitude == 1 ? 'thousand' : illionRepresentation);
		}
	}

	public static function getMinAndMax(value1:Float, value2:Float):Array<Float>
	{
		var minAndMaxs = new Array<Float>();

		var min = Math.min(value1, value2);
		var max = Math.max(value1, value2);

		minAndMaxs.push(min);
		minAndMaxs.push(max);

		return minAndMaxs;
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	inline public static function clamp(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars:EReg = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String> {
		final daList:Array<String> = string.trim().split('\n');
		return [for(i in 0...daList.length) daList[i].trim()];
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		sprite.useFramePixels = true;
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.framePixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		sprite.useFramePixels = false;
		return maxKey;
	}

	/**
		Funny handler for `Application.current.window.alert` that *doesn't* crash on Linux and shit.

		@param message Message of the error.
		@param title Title of the error.

		@author Leather128
	**/
	public static function coolError(message:Null<String> = null, title:Null<String> = null):Void {
		#if !linux
		lime.app.Application.current.window.alert(message, title);
		#else
		trace(title + " - " + message, ERROR);

		var text:FlxText = new FlxText(8, 0, 1280, title + " - " + message, 24);
		text.color = FlxColor.RED;
		text.borderSize = 1.5;
		text.borderColor = FlxColor.BLACK;
		text.scrollFactor.set();
		text.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		FlxG.state.add(text);

		FlxTween.tween(text, {alpha: 0, y: 8}, 5, {
			onComplete: function(_) {
				FlxG.state.remove(text);
				text.destroy();
			}
		});
		#end
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function getNoteAmount(song:SwagSong, ?bothSides:Bool = true, ?oppNotes:Bool = false):Int {
		var total:Int = 0;
		for (section in song.notes) {
			if (bothSides) total += section.sectionNotes.length;
			else
			{
				for (songNotes in section.sectionNotes)
				{
					if (!oppNotes && (songNotes[1] < 4 ? section.mustHitSection : !section.mustHitSection)) total += 1;
					if (oppNotes && (songNotes[1] < 4 ? !section.mustHitSection : section.mustHitSection)) total += 1;
				}
			}
		}
		return total;
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		return '$company/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
	}

	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch(border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}

	public static function showPopUp(message:String, title:String):Void
	{
		#if (!ios || !iphonesim)
		try
		{
			lime.app.Application.current.window.alert(message, title);
		}
		catch (e:Dynamic)
			trace('$title - $message');
		#else
		trace('$title - $message');
		#end
	}
}
