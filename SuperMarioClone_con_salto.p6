#!/usr/bin/env perl6
#
# Tilengine perspective projection demo
#   Cursors or joystick d-pad: scroll
# 

# imports
use NativeCall;

use lib '../bindings/perl6';
use Tilengine;

my $tln = Tilengine.new();

# constants
constant WIDTH  = 400;
constant HEIGHT = 240;

# layers
enum <LAYER_FOREGROUND LAYER_BACKGROUND MAX_LAYER>;

class Layer {
    has Pointer $.tilemap is rw;
    has Pointer $.tileset is rw;
}

my Layer @layers;

# helper for loading a related tileset + tilemap and configure the appropiate layer
sub LoadLayer (Int $index, $name) {
	my $filename;
	my Layer $layer = Layer.new;
	@layers[$index] = $layer;

	# load tileset
	$filename = "$name.tsx";
	
	$layer.tileset = $tln.LoadTileset($filename);

	# load tilemap
	$filename = "$name.tmx";
	$layer.tilemap = $tln.LoadTilemap($filename, "");

	$tln.SetLayer($index, $layer.tileset, $layer.tilemap);
}

# helper for freeing a tileset + tilemap
sub FreeLayer (Int $index) {
	my Layer $layer = @layers[$index];
	
	$tln.DeleteTileset($layer.tileset);
	$tln.DeleteTilemap($layer.tilemap);
}

my Pointer $sp;
my Pointer $seq_coin;
my Pointer $seq_question;
my Pointer $seq_walking;
my Pointer $spriteset;
my Int  $frame     = 0;
my Int  $player_x  = -16;
my Real $player_y  = 160.0;
my Real $base      = 160.0;
my Real $velocidad = 0.0;

# basic setup
$tln.Init(WIDTH, HEIGHT, MAX_LAYER,1,3);
#$tln.CreateWindow("overlay.bmp", $tln.CWF_VSYNC);
$tln.CreateWindow("", CWF_VSYNC);
$tln.SetBGColor(0, 96, 184);
$tln.SetLoadPath("assets/");

# setup layers
LoadLayer(LAYER_FOREGROUND, "smw_foreground");
LoadLayer(LAYER_BACKGROUND, "smw_background");
$tln.SetLayerPosition(LAYER_FOREGROUND, 0,48);
$tln.SetLayerPosition(LAYER_BACKGROUND, 0,80);

# setup sprite
$spriteset = $tln.LoadSpriteset("smw_sprite");
$tln.SetSpriteSet(0, $spriteset);
$tln.SetSpritePicture(0, 0);
$tln.SetSpritePosition(0, $player_x, $player_y.Int);

#  setup animations
$sp           = $tln.LoadSequencePack("sequences.sqx");
$seq_coin     = $tln.FindSequence($sp, "seq_coin");
$seq_question = $tln.FindSequence($sp, "seq_question");
$seq_walking  = $tln.FindSequence($sp, "seq_walking");
$tln.SetTilesetAnimation(0, LAYER_FOREGROUND, $seq_coin);
$tln.SetTilesetAnimation(1, LAYER_FOREGROUND, $seq_question);
$tln.SetSpriteAnimation(2, 0, $seq_walking, 0);

#  main loop
my $pulsado   = 0;
my $hay_salto = 0;

while $tln.ProcessWindow() {
    $player_x += 1;
    if $player_x >= WIDTH { $player_x = -16 }

    # process user input
    $pulsado = $tln.GetInput(INPUT_UP) ?? 1 !! 0;

    if $pulsado {
    	if not $hay_salto {
	    if $player_y == $base {
		if $velocidad > -16 {
		    $velocidad -= 8;
		}
	    }
	}
    }
    else {
	if $velocidad == 0 {
	    $hay_salto = 0;
	}
    }

    caer();

    $tln.SetSpritePosition(0, $player_x, $player_y.Int);
    $tln.DrawFrame($frame++);
}

# gravedad
sub caer {
    return if $velocidad == 0 and $player_y == $base;

    $player_y += $velocidad;
    $velocidad += 0.5;
    $player_x += 1;

    if abs($velocidad) < 2 and abs($player_y - $base) < 2 {
	    $player_y = $base;
	    $velocidad = 0;
	    return;
    }

    if $player_y > $base {
	$player_y = $base;
	$velocidad = -$velocidad ÷ 4;
    }
}

# deinit
FreeLayer(LAYER_FOREGROUND);
FreeLayer(LAYER_BACKGROUND);
$tln.DeleteSequencePack($sp);
$tln.DeleteWindow();
$tln.Deinit();


