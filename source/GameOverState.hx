package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class GameOverState extends FlxTransitionableState
{
	var bfX:Float = 0;
	var bfY:Float = 0;

	var bg:FlxSprite;

	public function new(x:Float, y:Float)
	{
		super();

		bfX = x;
		bfY = y;
	}

	override function create()
	{
		bg = new FlxSprite(-80).loadGraphic(AssetPaths.menuDesat__png);
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0xFF333333;
		add(bg);

		FlxG.sound.play(AssetPaths.death__ogg);

		var loser:FlxSprite = new FlxSprite(100, 100);
		var loseTex = FlxAtlasFrames.fromSparrow(AssetPaths.lose__png, AssetPaths.lose__xml);
		loser.frames = loseTex;
		loser.animation.addByPrefix('lose', 'lose', 24, false);
		loser.animation.play('lose');
		add(loser);

		var restart:FlxSprite = new FlxSprite(500, 50).loadGraphic(AssetPaths.restart__png);
		restart.setGraphicSize(Std.int(restart.width * 0.6));
		restart.updateHitbox();
		restart.alpha = 0;
		restart.antialiasing = true;
		add(restart);

		FlxG.sound.music.fadeOut(3, FlxG.sound.music.volume * 0.6);

		FlxG.sound.playMusic(AssetPaths.gameOver__ogg);

		FlxTween.tween(restart, {alpha: 1}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(restart, {y: restart.y + 40}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});

		super.create();
	}

	private var fading:Bool = false;

	override function update(elapsed:Float)
	{
		var pressed:Bool = FlxG.keys.justPressed.ANY;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		if (FlxG.keys.pressed.ENTER)
		{
			resume();
		}

		if (FlxG.keys.pressed.ESCAPE)
			{
				FlxG.sound.music.stop();
	
				if (PlayState.isStoryMode)
					FlxG.switchState(new StoryMenuState());
				else
					FlxG.switchState(new FreeplayState());
			}

		if (gamepad != null)
		{
			if (gamepad.justPressed.ANY)
				pressed = true;
		}

		pressed = false;

		if (pressed && !fading)
		{
			fading = true;
			FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween)
			{
				FlxG.sound.music.stop();
				FlxG.switchState(new PlayState());
			});
		}
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function resume():Void
		{
			if (!isEnding)
			{
				isEnding = true;
				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.music.stop();
				FlxG.sound.play('assets/music/gameOverEnd' + TitleState.soundExt);
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
					{
						FlxG.switchState(new PlayState());
					});
				});
			}
		}
}
