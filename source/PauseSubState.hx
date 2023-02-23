package;

import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxUIButton>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Toggle Practice Mode', 'Toggle Botplay', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();

		FlxG.mouse.visible = true;

		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath('pause')), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var backingThing:FlxUI9SliceSprite = new FlxUI9SliceSprite(0, 0, Paths.image('button'), new openfl.geom.Rectangle(0, 0, 48, 48), FlxUIAssets.SLICE9_BUTTON);
		backingThing.resize(330, 350);
		backingThing.scale.set(2, 2);
		backingThing.updateHitbox();
		backingThing.screenCenter();
		add(backingThing);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("arial.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font("arial.ttf"), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 64, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font("arial.ttf"), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font("arial.ttf"), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		for(i in grpMenuShit.members)
		{
			if(FlxG.mouse.overlaps(i))
			{
				i.color = FlxColor.LIME;
			}
			else
			{
				i.color = FlxColor.WHITE;
			}

			if(FlxG.mouse.overlaps(i) && FlxG.mouse.justPressed)
			{
				doButton(i.ID);
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function regenMenu():Void
	{
		for (i in 0...menuItems.length)
		{
			var item = new FlxUIButton(0, 170 + (80 * i), menuItems[i], null, true, false);
			item.loadGraphicSlice9([Paths.image('button'), Paths.image('button'), Paths.image('button')], 18, 18, [[6, 6, 11, 11], [6, 6, 11, 11], [6, 6, 11, 11]]);
			item.resize(275, 30);
			item.scale.set(2, 2);
			item.updateHitbox();
			item.label.fieldWidth = 550;
			item.label.setFormat(Paths.font("arial.ttf"), 24, FlxColor.WHITE, CENTER);
			item.screenCenter(X);
			item.ID = i;

			grpMenuShit.add(item);
		}
		curSelected = 0;
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}

	function doButton(which:Int = 0) 
	{
		switch (menuItems[which])
		{
			case "Resume":
				FlxG.mouse.visible = false;
				close();
			case 'Toggle Practice Mode':
				PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
				practiceText.visible = PlayState.instance.practiceMode;
			case "Restart Song":
				restartSong();
			case 'Toggle Botplay':
				PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
				PlayState.instance.botplayImg.visible = PlayState.instance.cpuControlled;
				PlayState.instance.botplayImg.alpha = 1;
				PlayState.instance.botplaySine = 0;
			case "Exit to menu":
				FlxG.mouse.visible = false;
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;

				WeekData.loadTheFirstEnabledMod();
				if(PlayState.isStoryMode) {
					MusicBeatState.switchState(new StoryMenuState());
				} else {
					MusicBeatState.switchState(new FreeplayState());
				}
				PlayState.cancelMusicFadeTween();
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				PlayState.chartingMode = false;
		}
	}
}