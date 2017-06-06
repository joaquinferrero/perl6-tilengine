#!/usr/bin/env perl6
# 
# Tilengine perspective projection demo
# Cursors or joystick d-pad: scroll
#

# imports
use NativeCall;
use lib "%*ENV<HOME>/Documentos/Desarrollo/Tilengine/perl6";
use Tilengine;

my $tln = Tilengine.new();

# constants
constant LAYER_FOREGROUND	= 0;
constant LAYER_BACKGROUND	= 1;
constant MAP_HORIZON		= 0;
constant MAP_TRACK		= 1;
constant WIDTH			= 400;
constant HEIGHT			= 240;

# module variables
my Int $x = -136;
my Int $y = 336;
my Num $s = 0e0;
my Num $a = 0.2e0;
my Int $angle = 0;
my Int $frame = 0;

my TLN_Affine $affine = TLN_Affine.new(angle => 0e0, sx => 1e0, sy => 1e0, dx => (WIDTH/2).Num, dy => HEIGHT.Num);

# setup engine
$tln.Init(WIDTH, HEIGHT, 2, 0, 0);
$tln.CreateWindow("overlay.bmp", Tilengine::CWF_VSYNC);
$tln.SetBGColor(0, 0, 0);

# load resources
my $tileset_horizon = $tln.LoadTileset("track1_bg.tsx");
my $tilemap_horizon = $tln.LoadTilemap("track1_bg.tmx", "Layer 1");
my $tileset_track   = $tln.LoadTileset("track1.tsx");
my $tilemap_track   = $tln.LoadTilemap("track1.tmx", "Layer 1");

# linear interpolation
my Int sub lerp ($x, $x0, $x1, $fx0, $fx1) {
	return ($fx0 + ($fx1 - $fx0) * ($x - $x0) / ($x1 - $x0)).Int;
}

my $scale_raster;

sub raster_callback (int32 $line) {
    if $line == 24 {
	$tln.SetLayer(LAYER_BACKGROUND, $tileset_track, $tilemap_track);
	$tln.SetLayerPosition(LAYER_BACKGROUND, $x.Int, $y.Int);
	$tln.DisableLayer(LAYER_FOREGROUND);
    }
    if $line > 24 {
	$scale_raster = lerp($line, 24, HEIGHT, 0.2, 5.0);
	$affine.sx = $scale_raster;
	$affine.sy = $scale_raster;		
	$tln.SetLayerTransform(LAYER_BACKGROUND, $affine.angle, $affine.dx, $affine.dy, $affine.sx, $affine.sy);
    }
}

# set raster callback
sub TLN_SetRasterCallback(&callback (int32)) is native('Tilengine') { * }
TLN_SetRasterCallback(&raster_callback);

# main loop
while $tln.ProcessWindow() {
    $tln.SetLayer(LAYER_FOREGROUND, $tileset_horizon, $tilemap_horizon);
    $tln.SetLayer(LAYER_BACKGROUND, $tileset_horizon, $tilemap_horizon);
    $tln.SetLayerPosition(LAYER_FOREGROUND, lerp($angle*2, 0,360, 0,256).Int, 24);
    $tln.SetLayerPosition(LAYER_BACKGROUND, lerp($angle, 0,360, 0,256).Int, 0);
    $tln.ResetLayerMode(LAYER_BACKGROUND);

    # input
    if $tln.GetInput(Tilengine::INPUT_LEFT)		{ $angle -= 2 }
    elsif $tln.GetInput(Tilengine::INPUT_RIGHT)	{ $angle += 2 }
    
    if $tln.GetInput(Tilengine::INPUT_UP) {
	$s += $a;
	if $s > 2e0 { $s = 2e0 }
    }
    elsif $s >= $a {
	$s -= $a;
    }
    
    if $tln.GetInput(Tilengine::INPUT_DOWN) {
	$s -= $a;
	if $s < -2e0 { $s = -2e0 }
    }
    elsif $s <= -$a {
	$s += $a;
    }

    # scroll
    if $s != 0 {
	    $angle = $angle % 360;
	    if $angle < 0 { $angle += 360 }

	    my Num $rad = $angle * π / 180;
	    $x += Int(sin($rad) * $s);
	    $y -= Int(cos($rad) * $s);
    }

    $affine.angle = $angle.Num;

    # render to window
    $tln.DrawFrame($frame);
    $frame += 1;
}

$tln.DeleteWindow();
$tln.Deinit();

=finish

