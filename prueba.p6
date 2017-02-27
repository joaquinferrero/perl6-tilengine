#!/usr/bin/env perl6
#use NativeCall;

use lib '../bindings/perl';
use Tilengine1;

my $LAYER_FOREGROUND = 0;
my $LAYER_BACKGROUND = 1;

sub SetupLayer($nlayer, $name) {
	my $tileset = TLN_LoadTileset($name ~ ".tsx");
	my $tilemap = TLN_LoadTilemap($name ~ ".tmx", "Layer 1");
	TLN_SetLayer($nlayer, $tileset, $tilemap);
}

TLN_Init(400, 240, 2, 80, 1);
TLN_CreateWindow("", (1 +< 1));

SetupLayer($LAYER_FOREGROUND, "Sonic_md_fg1");
SetupLayer($LAYER_BACKGROUND, "Sonic_md_bg1");


TLN_SetBGColor(10, 10, 0);

my $frame = 0;

while TLN_ProcessWindow() {

	TLN_SetLayerPosition($LAYER_FOREGROUND, $frame, 0);
	TLN_DrawFrame($frame++);
}

TLN_DeleteWindow();
TLN_Deinit();
