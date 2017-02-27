#!/usr/bin/env perl6
# 
# Tilengine scaling & transparency demo
#   Cursors or joystick d-pad: scroll
#   Z/X or joystick buttons 1/2: modify scale factor
#   C/V or joystick buttons 3/4: modify transparency
#

# imports
use lib '../bindings/perl';
use Tilengine1;

my $tln = Tilengine.new();

# constants
constant LAYER_FOREGROUND = 0;
constant LAYER_BACKGROUND = 1;
constant WIDTH		  = 400;
constant HEIGHT		  = 240;
constant MIN_SCALE	  = 50;
constant MAX_SCALE	  = 200;

# module variables
my Int  $xpos  = 0;
my Int  $ypos  = 192;
my Int  $scale = 100;
my Int  $alpha = 255;
my Int  $frame = 0;

# linear interpolation
sub lerp ($x, $x0, $x1, $fx0, $fx1) {
	return $fx0 + ($fx1 - $fx0) * ($x - $x0) / ($x1 - $x0);
}

=finish
# setup layer helper
def SetupLayer (nlayer, name):
	tileset = tln.LoadTileset (name + ".tsx")
	tilemap = tln.LoadTilemap (name + ".tmx", "Layer 1")
	tln.SetLayer (nlayer, tileset, tilemap)	

# setup engine
tln.Init (WIDTH, HEIGHT, 2,0,0)
tln.CreateWindow ("overlay3.bmp", tln.CWF_VSYNC)
tln.SetBGColor (34,136,170)

# setup layers
SetupLayer (LAYER_FOREGROUND, "psycho")
SetupLayer (LAYER_BACKGROUND, "rolo")

# main loop
while tln.ProcessWindow ():
	# user input
	if tln.GetInput (tln.INPUT_LEFT):
		xpos -= 1
	if tln.GetInput (tln.INPUT_RIGHT):
		xpos += 1
	if tln.GetInput (tln.INPUT_UP) and ypos > 0:
		ypos -= 1
	if tln.GetInput (tln.INPUT_DOWN):
		ypos += 1
	if tln.GetInput (tln.INPUT_A) and scale < MAX_SCALE:
		scale += 1
	if tln.GetInput (tln.INPUT_B) and scale > MIN_SCALE:
		scale -= 1
	if tln.GetInput (tln.INPUT_C) and alpha < 255:
		alpha += 2
	if tln.GetInput (tln.INPUT_D) and alpha > 1:
		alpha -= 2

	# calculate scale factor from fixed point base
	fgscale = scale/100.0
	bgscale = lerp(scale, MIN_SCALE,MAX_SCALE, 0.75,1.5)

	# scale dependant lower clipping
	maxy = 640 - (HEIGHT*100/scale)
	if ypos > maxy:
		ypos = maxy
	
	# update position
	bgypos = lerp(scale,MIN_SCALE,MAX_SCALE, 0,80)
	tln.SetLayerPosition (LAYER_FOREGROUND, xpos*2, ypos)
	tln.SetLayerPosition (LAYER_BACKGROUND, xpos, bgypos)
	tln.SetLayerScaling (LAYER_FOREGROUND, fgscale, fgscale)
	tln.SetLayerScaling (LAYER_BACKGROUND, bgscale, bgscale)

	# update transparency
	if alpha < 255:
		tln.SetLayerBlendMode (LAYER_FOREGROUND, tln.BLEND_MIX, alpha)
	else:
		tln.SetLayerBlendMode (LAYER_FOREGROUND, tln.BLEND_NONE, 0)
	
	# render to the window
	tln.DrawFrame (frame)
	frame += 1
	
tln.DeleteWindow ()
tln.Deinit ()
