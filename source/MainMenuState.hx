package;

//wtf is this and why was it there
//import flixel.addons.editors.spine.FlxSpine;
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
	var elapsedtime:Float = 0;

	public static var psychEngineVersion:String = 'Demo'; //This is also used for Discord RPC

	var starsBg:FlxBackdrop;
	var starsFg:FlxBackdrop;

	var storyButt:FlxUIButton;
	var freeButt:FlxUIButton;
	var optButt:FlxSprite;

	var titleGuys:Array<FlxSprite> = [];
	var titleSpeeds:Array<Array<Float>> = [];

	var swagShader:ColorSwap = null;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
		}

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		swagShader = new ColorSwap();

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

		//the debug messages are kinda ridiculous but the postirony meme shit was hell so im coming in prepared
		for(i in 0...6)
		{
			//trace('guy $i prep');
			var guysArray:Array<String> = ['title_bf', 'title_gf', 'title_shh', 'title_fissure', 'title_gray', 'title_purp'];
			var scaley:Float = FlxG.random.float(0.65, 0.95);

			var guyNew = new FlxSprite(0, 0).loadGraphic(Paths.image(guysArray[i]));
			//trace('guy $i made');

			guyNew.scale.set(scaley, scaley);
			guyNew.updateHitbox();
			//trace('guy $i scaled');

			guyNew.setPosition(FlxG.random.float(10, FlxG.width - guyNew.width - 10), FlxG.random.float(10, FlxG.height - guyNew.height - 10));

			guyNew.antialiasing = true;
			guyNew.angle = FlxG.random.float(0, 359);
			//trace('guy $i angled');

			guyNew.ID = i;
			add(guyNew);
			//trace('guy $i added');

			guyNew.shader = swagShader.shader;
			titleGuys.push(guyNew);
			var thingyTuh:Float = FlxG.random.float(0.9, 2.25);
			titleSpeeds.push([thingyTuh, thingyTuh, thingyTuh]);
			//trace('guy $i finished, moving on');
		}

		var logoStill = new FlxSprite(0, 25).loadGraphic(Paths.image('logostill'));
		logoStill.screenCenter(X);
		logoStill.antialiasing = true;
		logoStill.shader = swagShader.shader;
		add(logoStill);

		storyButt = new FlxUIButton(398.25, 467.5, 'Story', null, true, false);
		storyButt.loadGraphicSlice9([Paths.image('button'), Paths.image('button'), Paths.image('button')], 18, 18, [[6, 6, 11, 11], [6, 6, 11, 11], [6, 6, 11, 11]]);
		storyButt.resize(229 / 2, 94 / 2);
		storyButt.scale.set(2, 2);
		storyButt.updateHitbox();
		storyButt.label.fieldWidth = 229;
		storyButt.label.setFormat(Paths.font("arial.ttf"), 36, FlxColor.WHITE, CENTER);
		//add(storyButt);

		freeButt = new FlxUIButton(398.25, 467.5, 'Demo', null, true, false);
		freeButt.loadGraphicSlice9([Paths.image('button'), Paths.image('button'), Paths.image('button')], 18, 18, [[6, 6, 11, 11], [6, 6, 11, 11], [6, 6, 11, 11]]);
		freeButt.resize(229, 94 / 2);
		freeButt.scale.set(2, 2);
		freeButt.updateHitbox();
		freeButt.label.fieldWidth = 229 * 2;
		freeButt.label.setFormat(Paths.font("arial.ttf"), 36, FlxColor.WHITE, CENTER);
		add(freeButt);

		optButt = new FlxSprite(588, 605).loadGraphic(Paths.image('settings'));
		optButt.updateHitbox();
		optButt.antialiasing = true;
		add(optButt);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Yet Another Among Us Mod " + psychEngineVersion, 12);
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
		if(FlxG.mouse.overlaps(optButt))
		{
			freeButt.color = FlxColor.WHITE;
			optButt.color = FlxColor.GRAY;
		}
		else if(FlxG.mouse.overlaps(freeButt))
		{
			freeButt.color = FlxColor.LIME;
			optButt.color = FlxColor.WHITE;
		}
		else
		{
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

				if(FlxG.mouse.overlaps(optButt))
				{
					MusicBeatState.switchState(new OptionsState());
				}
				else if(FlxG.mouse.overlaps(freeButt))
				{
					MusicBeatState.switchState(new FreeplayState());
				}
			}
		}

		elapsedtime += elapsed;

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
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

		for(guy in titleGuys)
		{
			if(guy != null)
			{
				//inaccurate and BAD
				/*if(guy.ID % 2 == 0)
				{
					guy.x += Math.sin((elapsedtime * titleSpeeds[guy.ID]) * 0.35);
					guy.y += Math.cos((elapsedtime * titleSpeeds[guy.ID]) * 0.35);
				}
				else
				{
					guy.x += Math.cos((elapsedtime * titleSpeeds[guy.ID]) * 0.35);
					guy.y += Math.sin((elapsedtime * titleSpeeds[guy.ID]) * 0.35);
				}*/

				//accurate and GOOD
				guy.x += (0.5 * titleSpeeds[guy.ID][0]);
				guy.y += (0.5 * titleSpeeds[guy.ID][1]);

				if(guy.x >= (FlxG.width - guy.width) || guy.x <= 0)
				{
					titleSpeeds[guy.ID][0] = titleSpeeds[guy.ID][0] * -1;
				}
				if(guy.y >= (FlxG.height - guy.height) || guy.y <= 0)
				{
					titleSpeeds[guy.ID][1] = titleSpeeds[guy.ID][1] * -1;
				}

				guy.angle += (0.5 * titleSpeeds[guy.ID][2]);
			}
		}
	}
}