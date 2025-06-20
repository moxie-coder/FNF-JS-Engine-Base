package options;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;

using StringTools;

class MiscSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Misc';
		rpcTitle = 'Miscellaneous Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Use JS Engine Recharts', //Name
			'If checked, songs will have an optional "JSHard" difficulty (if available.)\nUse this difficulty for the JSE-specific recharts.', //Description
			'JSEngineRecharts', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Always Play Cutscenes', //Name
			'If checked, cutscenes will always play even if you\nenter the song through Freeplay.', //Description
			'alwaysTriggerCutscene', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Disable Splash Screen', //Name
			'If checked, the splash screen gets disabled on startup.', //Description
			'disableSplash', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		#if APRIL_FOOLS
			var option:Option = new Option('Disable April Fools', //Name
				'If checked, the April Fools related things gets ignored.', //Description
				'disableAprilFools', //Save data variable name
				'bool', //Variable type
				false); //Default value
			addOption(option);
		#end
		//credit to Nael2xd for the idea
		var option:Option = new Option('Rainbow Note Shift Speed', //Name
			'Changes the amount of time between 1 cycle for Rainbow Notes.\n(Make sure you have your note colors set to "Rainbow" to see this in action!)', //Description
			'rainbowTime', //Save data variable name
			'float', //Variable type
			5.0); //Default value
		option.scrollSpeed = 4;
		option.minValue = 0.01;
		option.maxValue = 100;
		option.changeValue = 0.01;
		option.decimals = 2; //lol
		option.displayFormat = '%vs';
		addOption(option);

		var option:Option = new Option('Autosave',
			'If checked, the Chart Editor will autosave.',
			'autosaveCharts',
			'bool',
			true);
		addOption(option);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		
		super();
	}
}