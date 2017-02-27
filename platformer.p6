#!/usr/bin/env perl6
#
# Tilengine perspective projection demo
#   Cursors or joystick d-pad: scroll
# 

# imports
use lib '../bindings/perl';
use Tilengine;

my $tln = Tilengine.new();

# constants
constant LAYER_FOREGROUND = 0;
constant LAYER_BACKGROUND = 1;

# module variables
my Int  $frame          = 0;
my Real $basepos        = 0;
my Real $speed          = 0;
my Real @pos_background = 0, 0, 0, 0, 0, 0;

# linear interpolation
sub lerp ($x, $x0, $x1, $fx0, $fx1) {
	return $fx0 + ($fx1 - $fx0) * ($x - $x0) / ($x1 - $x0);
}

# setup layer helper
sub SetupLayer ($nlayer, $name) {
    my $tileset = $tln.LoadTileset($name ~ ".tsx");
    my $tilemap = $tln.LoadTilemap($name ~ ".tmx", "Layer 1");
    $tln.SetLayer($nlayer, $tileset, $tilemap);
}

# raster effect
sub raster_effect ($line) {
    my Real $pos = -1;
    
    given $line {
    	when	 0	{ $pos = @pos_background[0]	}
	when	32	{ $pos = @pos_background[1]	}
	when	48	{ $pos = @pos_background[2]	}
	when	64	{ $pos = @pos_background[3]	}
	when   112	{ $pos = @pos_background[4]	}
	when $_ >= 152	{ $pos = lerp($line, 152, 224, @pos_background[4], @pos_background[5]) }
    }

    if $pos != -1 {
	$tln.SetLayerPosition(LAYER_BACKGROUND, $pos.Int, 0);
    }

    if $line == 0 {
	$tln.SetBGColor(28,0,140);
    }
    elsif $line == 144 {
	$tln.SetBGColor(0,128,238);
    }
}

# initialise
$tln.Init(400,240,2,80,1);
#$tln.CreateWindow("overlay.bmp", $tln.CWF_VSYNC);
$tln.CreateWindow("", $tln.CWF_S1);

# setup layers
SetupLayer(LAYER_FOREGROUND, "Sonic_md_fg1");
SetupLayer(LAYER_BACKGROUND, "Sonic_md_bg1");

# color cycle animation
my $sp       = $tln.LoadSequencePack("Sonic_md_seq.sqx");
my $sequence = $tln.FindSequence($sp, "seq_water");
my $palette  = $tln.GetLayerPalette(LAYER_BACKGROUND);
$tln.SetPaletteAnimation(0, $palette, $sequence, True);
	
# main loop
while $tln.ProcessWindow() {

    # process user input
    if $tln.GetInput($tln.INPUT_RIGHT) {
	$speed += 0.06;
	if $speed > 3.0 {
	    $speed = 3.0;
	}
    }
    elsif $speed > 0.0 {
	$speed -= 0.06;
	if $speed < 0.0 {
	    $speed = 0.0;
	}
    }

    if $tln.GetInput($tln.INPUT_LEFT) {
	$speed -= 0.06;
	if $speed < -3.0 {
	    $speed = -3.0;
	}
    }
    elsif $speed < 0.0 {
	$speed += 0.06;
	if $speed > 0.0 {
	    $speed = 0.0;
	}
    }

    # scroll
    $basepos                += $speed;
    my Real $pos_foreground  = $basepos * 3;
    $tln.SetLayerPosition(LAYER_FOREGROUND, $pos_foreground.Int, 0);

    @pos_background[0] = $basepos * 0.562;
    @pos_background[1] = $basepos * 0.437;
    @pos_background[2] = $basepos * 0.375;
    @pos_background[3] = $basepos * 0.625;
    @pos_background[4] = $basepos * 1.0;
    @pos_background[5] = $basepos * 2.0;
    
    # draw frame line by line doing raster effects
    $tln.BeginWindowFrame($frame);
    my $line = 0;
    my $drawing = True;
    while $drawing {
	raster_effect($line);
	$line += 1;
	$drawing = $tln.DrawNextScanline();
    }
    $tln.EndWindowFrame();
    $frame += 1;
}
	
$tln.DeleteWindow();
$tln.Deinit();

