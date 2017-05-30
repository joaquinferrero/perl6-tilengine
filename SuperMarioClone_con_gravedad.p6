#!/usr/bin/env perl6
#
# SuperMarioClone demo
#   Cursors or joystick d-pad: move Mario
#   Z : jump
#

# imports
use NativeCall;

use lib "%*ENV<HOME>/Documentos/Desarrollo/Tilengine/perl6";
use Tilengine;

my $tln = Tilengine.new();

# constants
constant WIDTH  = 400;
constant HEIGHT = 240;

# layers
enum <LAYER_FOREGROUND LAYER_BACKGROUND MAX_LAYER>;

class Layer {
    has Pointer[TLN_Tilemap] $.tilemap is rw;
    has Pointer[TLN_Tileset] $.tileset is rw;
}

my Layer @layers[MAX_LAYER];

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

# Tiles
my  $tile = Tile.new;
$tile.index = 56;
$tile.flags = Tilengine::FLAG_NONE;

my Pointer[TLN_SequencePack]	 $sp;
my Pointer[TLN_Sequence]	 $seq_coin;
my Pointer[TLN_Sequence]	 $seq_question;
my Pointer[TLN_Sequence]	 $seq_walking;
my Pointer[TLN_Spriteset]	 $spriteset;
my Int  $frame     = 0;
my Int  $player_x  = 90;
my Real $player_y  = 200.0;
my Real $base      = $player_y;
my Real $velocidad = 0.0;

# basic setup
$tln.Init(WIDTH, HEIGHT, MAX_LAYER,1,3);
$tln.CreateWindow("overlay.bmp", Tilengine::CWF_VSYNC);
$tln.SetBGColor(0, 96, 184);
$tln.SetLoadPath("assets/");

# setup layers
my Int $fore_x = 0;
LoadLayer(LAYER_FOREGROUND, "smw_foreground");
LoadLayer(LAYER_BACKGROUND, "smw_background");
$tln.SetLayerPosition(LAYER_FOREGROUND, $fore_x,48);
$tln.SetLayerPosition(LAYER_BACKGROUND, $fore_x,80);

# setup sprite
$spriteset = $tln.LoadSpriteset("smw_sprite");
$tln.SetSpriteSet(0, $spriteset);
$tln.ConfigSprite(0, $spriteset, Tilengine::FLAG_NONE);
$tln.SetSpritePicture(0, 0);
$tln.SetSpritePosition(0, $player_x, $player_y.Int);

# setup animations
$sp           = $tln.LoadSequencePack("sequences.sqx");
$seq_coin     = $tln.FindSequence($sp, "seq_coin");
$seq_question = $tln.FindSequence($sp, "seq_question");
$seq_walking  = $tln.FindSequence($sp, "seq_walking");
$tln.SetTilesetAnimation(0, LAYER_FOREGROUND, $seq_coin);
$tln.SetTilesetAnimation(1, LAYER_FOREGROUND, $seq_question);
$tln.SetSpriteAnimation(2, 0, $seq_walking, 0);

# main loop
my Bool $pulsado               = False;
my Bool $hay_salto             = False;
my Bool $segundo_salto_posible = False;
my Bool $liberado              = False;
my $sentido                    = 0;
my Int $x_tile;
my Int $y_tile;

while $tln.ProcessWindow() {

    # cálculo posición fondo
    if $player_x > 300 {
    	my $diff = ($player_x - 300) ÷ 20;
    	$fore_x += $diff.Int;
    	$player_x -= $diff.Int;
    }
    elsif $player_x < 100 {
    	my $diff = (100 - $player_x) ÷ 20;
    	$fore_x -= $diff.Int;
    	$player_x += $diff.Int;
    }

    $tln.SetLayerPosition(LAYER_FOREGROUND, $fore_x, 48);
    $tln.SetLayerPosition(LAYER_BACKGROUND, ($fore_x ÷ 2).Int, 80);

    #if abs($fore_x) > 1312 { $fore_x = 0 }

    # process user input
    $pulsado = $tln.GetInput(Tilengine::INPUT_UP) ?? True !! False;

    if $pulsado {
    	if not $hay_salto {
	    #if $player_y >= $base or $tile.index == 12 {
		$tln.DisableAnimation(2);
		$tln.SetSpritePicture(0, 7);
		$velocidad = -5;
		$hay_salto = True;
	    	$segundo_salto_posible = True;
	    	$liberado = False;
	    #}
	}
	else {
	    if $segundo_salto_posible and $liberado and $velocidad > -2 {
	    	$segundo_salto_posible = False;
	    	$velocidad -= 3;
	    }
	}
    }
    else {
	$liberado = True;
    }

    caer() if $hay_salto;

    if $tln.GetInput(Tilengine::INPUT_RIGHT) {
	$player_x += 2;
	if $sentido == 1 {
	    $tln.ConfigSprite(0, $spriteset, 0);
	    $sentido = 0;
	}
	if not $hay_salto and not $tln.GetAnimationState(2) {
	    $tln.SetSpriteAnimation(2, 0, $seq_walking, 0);
	}
    }
    elsif $tln.GetInput(Tilengine::INPUT_LEFT ) {
	$player_x -= 2;
	if $sentido == 0 {
	    $tln.ConfigSprite(0, $spriteset, Tilengine::FLAG_FLIPX);
	    $sentido = 1;
	}
	if not $hay_salto and not $tln.GetAnimationState(2) {
	    $tln.SetSpriteAnimation(2, 0, $seq_walking, 0);
	}
    }
    else {
	if not $hay_salto {
	    if $tln.GetAnimationState(2) {
		$tln.DisableAnimation(2);
	    }
	    $tln.SetSpritePicture(0, 0);
	}
    }

    #if $player_x >= WIDTH { $player_x = -15     }
    #if $player_x <= -16   { $player_x = WIDTH-1 }

    $tln.SetSpritePosition(0, $player_x, $player_y.Int);



    $x_tile = Int(($player_x + $fore_x) ÷ 16 + 1);
    $y_tile = Int(($player_y          ) ÷ 16 + 5);
    $tln.GetTilemapTile(@layers[LAYER_FOREGROUND].tilemap, $y_tile, $x_tile, $tile);
    $tln.SetTilemapTile(@layers[LAYER_FOREGROUND].tilemap, 5, $x_tile, $tile);

    $tln.DrawFrame($frame++);

    #sleep 0.01;
}

# gravedad
sub caer {

    $player_y += $velocidad;
    $velocidad += 0.2;
    $player_x += $sentido == 0 ?? 1 !! -1;

    if $velocidad > 0 {
    	$tln.SetSpritePicture(0, 8);	# cayendo

	if $player_y > $base or $tile.index == 12 {
	    $player_y = $player_y >= $base ?? $base !! ($y_tile-5)*16;
	    $hay_salto = False;
	    return;
	}
	#    $velocidad = -$velocidad ÷ 4;	# rebote
	#    if abs($velocidad) < 2 { $velocidad = 0 }
	#    $tln.SetSpritePicture(0, 10);
	#    return;
	#}

    }

    #if abs($velocidad) < 2 and abs($player_y - $base) < 2 {
    #        $player_y = $base;
    #        $velocidad = 0;
    #        return;
    #}

}

# deinit
FreeLayer(LAYER_FOREGROUND);
FreeLayer(LAYER_BACKGROUND);
$tln.DeleteSequencePack($sp);
$tln.DeleteWindow();
$tln.Deinit();

