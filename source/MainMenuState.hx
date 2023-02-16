package;

import flixel.addons.editors.spine.FlxSpine;
import options.OptionsState;
import options.BaseOptionsMenu;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.display.FlxBackdrop;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1'; //This is also used for Discord RPC

	var starsBg:FlxBackdrop;
	var starsFg:FlxBackdrop;

	var storyButt:FlxUIButton;
	var freeButt:FlxUIButton;
	var optButt:FlxSprite;

	var titleGuys:Array<FlxSprite>;
	var titleSpeeds:Array<Float>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		starsBg = new FlxBackdrop(Paths.image('stars'));
		starsBg.scale.set(1.25, 1.25);
		starsBg.updateHitbox();
		starsBg.x -= 150;
		starsBg.y += 50;
		starsBg.antialiasing = true;
		starsBg.scrollFactor.set(0.25, 0.25);
		starsBg.alpha = 0.75;
		add(starsBg);

		starsFg = new FlxBackdrop(Paths.image('stars'));
		starsFg.scale.set(1.75, 1.75);
		starsFg.updateHitbox();
		starsFg.antialiasing = true;
		add(starsFg);

		/*for(i in 0...4)
		{
			var guyNew = new FlxSprite()
		}*/

		var logoStill = new FlxSprite(0, 25).loadGraphic(Paths.image('logostill'));
		logoStill.screenCenter(X);
		logoStill.antialiasing = true;
		add(logoStill);

		storyButt = new FlxUIButton(398.25, 467.5, 'Story', null, true, false);
		storyButt.loadGraphicSlice9([Paths.image('button'), Paths.image('button'), Paths.image('button')], 18, 18, [[6, 6, 11, 11], [6, 6, 11, 11], [6, 6, 11, 11]]);
		storyButt.resize(229 / 2, 94 / 2);
		storyButt.scale.set(2, 2);
		storyButt.updateHitbox();
		storyButt.label.fieldWidth = 229;
		storyButt.label.setFormat(Paths.font("arial.ttf"), 36, FlxColor.WHITE, CENTER);
		add(storyButt);

		freeButt = new FlxUIButton(649.45, 467.5, 'Freeplay', null, true, false);
		freeButt.loadGraphicSlice9([Paths.image('button'), Paths.image('button'), Paths.image('button')], 18, 18, [[6, 6, 11, 11], [6, 6, 11, 11], [6, 6, 11, 11]]);
		freeButt.resize(229 / 2, 94 / 2);
		freeButt.scale.set(2, 2);
		freeButt.updateHitbox();
		freeButt.label.fieldWidth = 229;
		freeButt.label.setFormat(Paths.font("arial.ttf"), 36, FlxColor.WHITE, CENTER);
		add(freeButt);

		optButt = new FlxSprite(588, 605).loadGraphic(Paths.image('settings'));
		optButt.updateHitbox();
		optButt.antialiasing = true;
		add(optButt);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Yet Another Among Us Mod v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("arial.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("arial.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		//so fuckign stupid
		if(FlxG.mouse.overlaps(storyButt))
		{
			storyButt.color = FlxColor.LIME;
			freeButt.color = FlxColor.WHITE;
			optButt.color = FlxColor.WHITE;
		}
		else if(FlxG.mouse.overlaps(optButt))
		{
			storyButt.color = FlxColor.WHITE;
			freeButt.color = FlxColor.WHITE;
			optButt.color = FlxColor.GRAY;
		}
		else if(FlxG.mouse.overlaps(freeButt))
		{
			freeButt.color = FlxColor.LIME;
			storyButt.color = FlxColor.WHITE;
			optButt.color = FlxColor.WHITE;
		}
		else
		{
			storyButt.color = FlxColor.WHITE;
			freeButt.color = FlxColor.WHITE;
			optButt.color = FlxColor.WHITE;
		}

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				if(FlxG.mouse.overlaps(storyButt) || FlxG.mouse.overlaps(freeButt) || FlxG.mouse.overlaps(optButt))
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.mouse.visible = false;
				}

				if(FlxG.mouse.overlaps(storyButt))
				{
					MusicBeatState.switchState(new StoryMenuState());
				}
				else if(FlxG.mouse.overlaps(optButt))
				{
					MusicBeatState.switchState(new OptionsState());
				}
				else if(FlxG.mouse.overlaps(freeButt))
				{
					MusicBeatState.switchState(new FreeplayState());
				}
			}
		}

		super.update(elapsed);

		if(starsBg != null)
		{
			starsBg.x += (10 * elapsed);
			starsBg.y += (10 * elapsed);
		}

		if(starsFg != null)
		{
			starsFg.x += (15 * elapsed);
			starsFg.y += (15 * elapsed);
		}
	}
}