use v6;
unit module Game::Engine::Tilengine:ver<0.0.1>:auth<Joaquin Ferrero (jferrero@gmail.com)>;

use NativeCall;

class Tile is repr('CStruct') is export {
    has int32 $.index is rw;
    has int32 $.flags is rw;
}

class Affine is repr('CStruct') is export  {
    has num32 $.angle is rw;
    has num32 $.dx    is rw;
    has num32 $.dy    is rw;
    has num32 $.sx    is rw;
    has num32 $.sy    is rw;
}

class Tilengine is export {
    # window creation flags
    method CWF_FULLSCREEN { 1 +< 0 }
    method CWF_VSYNC	  { 1 +< 1 }
    method CWF_S1	  { 1 +< 2 }
    method CWF_S2	  { 2 +< 2 }
    method CWF_S3	  { 3 +< 2 }
    method CWF_S4	  { 4 +< 2 }
    method CWF_S5	  { 5 +< 2 }

    # inputs
    method INPUT_NONE 	{ 0 }
    method INPUT_UP 	{ 1 }
    method INPUT_DOWN 	{ 2 }
    method INPUT_LEFT 	{ 3 }
    method INPUT_RIGHT	{ 4 }
    method INPUT_A 	{ 5 }
    method INPUT_B 	{ 6 }
    method INPUT_C 	{ 7 }
    method INPUT_D 	{ 8 }

    # flags
    method FLAG_NONE	 {	 0 }
    method FLAG_FLIPX	 { 1 +< 15 }
    method FLAG_FLIPY	 { 1 +< 14 }
    method FLAG_ROTATE	 { 1 +< 13 }
    method FLAG_PRIORITY { 1 +< 12 }

    # blend modes
    method BLEND_NONE	{ 0 }
    method BLEND_MIX	{ 1 }
    method BLEND_ADD	{ 2 }
    method BLEND_SUB	{ 3 }
    method BLEND_MOD	{ 4 }
    method MAX_BLEND	{ 5 }

    my sub TLN_Init(int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * };
    method Init (int32 $hres, int32 $vres, int $numlayers, int $numsprites, int $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) };

    my sub TLN_CreateWindow(Str, int32) returns bool is native('Tilengine') { * };
    method CreateWindow(Str $overlay, int32 $flags) { TLN_CreateWindow($overlay, $flags) };

    my sub TLN_LoadTileset(Str) returns Pointer is native('Tilengine') { * };
    method LoadTileset(Str $filename) { TLN_LoadTileset($filename) };

    my sub TLN_SetTilesetAnimation(int32, int32, Pointer) returns Pointer is native('Tilengine') { * };
    method SetTilesetAnimation(int32 $index, int32 $nlayer, Pointer $sequence) { TLN_SetTilesetAnimation($index, $nlayer, $sequence) };

    my sub TLN_LoadTilemap(Str, Str) returns Pointer is native('Tilengine') { * };
    method LoadTilemap(Str $filename, Str $layername) { TLN_LoadTilemap($filename, $layername) };

    my sub TLN_GetTilemapTile(Pointer, int32, int32, Tile) returns bool is native('Tilengine') { * };
    method GetTilemapTile(Pointer $tilemap, int32 $row, int32 $col, Tile $tile) { TLN_GetTilemapTile($tilemap, $row, $col, $tile) };

    my sub TLN_SetTilemapTile(Pointer, int32, int32, Tile) returns bool is native('Tilengine') { * };
    method SetTilemapTile(Pointer $tilemap, int32 $row, int32 $col, Tile $tile) { TLN_SetTilemapTile($tilemap, $row, $col, $tile) };

    my sub TLN_SetLayer(int32, Pointer, Pointer) is native('Tilengine') { * };
    method SetLayer(int32 $nlayer, Pointer $tileset, Pointer $tilemap) { TLN_SetLayer($nlayer, $tileset, $tilemap) };

    my sub TLN_SetLayerBlendMode(int32, int32, uint8) returns bool is native('Tilengine') { * };
    method SetLayerBlendMode(int32 $nlayer, int32 $mode, uint8 $factor) { TLN_SetLayerBlendMode($nlayer, $mode, $factor) };

    my sub TLN_SetLayerScaling(int32, num32, num32) returns bool is native('Tilengine') { * };
    method SetLayerScaling(int32 $nlayer, num32 $sx, num32 $sy) { TLN_SetLayerScaling($nlayer, $sx, $sy) };

    my sub TLN_SetLayerPosition(int32, int32, int32) returns bool is native('Tilengine') { * };
    method SetLayerPosition(int32 $nlayer, int32 $hstart, int32 $vstart) { TLN_SetLayerPosition($nlayer, $hstart, $vstart) };

    my sub TLN_ResetLayerMode(int32) returns bool is native('Tilengine') { * };
    method ResetLayerMode(int32 $nlayer) { TLN_ResetLayerMode($nlayer) };

    my sub TLN_LoadSequencePack(Str) returns Pointer is native('Tilengine') { * };
    method LoadSequencePack(Str $filename) { TLN_LoadSequencePack($filename) };

    my sub TLN_SetLoadPath(Str) is native('Tilengine') { * };
    method SetLoadPath(Str $path) { TLN_SetLoadPath($path) };

    my sub TLN_LoadSpriteset(Str) returns Pointer is native('Tilengine') { * };
    method LoadSpriteset(Str $name) { TLN_LoadSpriteset($name) };

    my sub TLN_SetSpriteSet(int32, Pointer) returns Pointer is native('Tilengine') { * };
    method SetSpriteSet(int32 $nsprite, Pointer $spriteset) { TLN_SetSpriteSet($nsprite, $spriteset) };

    my sub TLN_ConfigSprite(int32, Pointer, int32) returns bool is native('Tilengine') { * };
    method ConfigSprite(int32 $nsprite, Pointer $spriteset, int32 $flags) { TLN_ConfigSprite($nsprite, $spriteset, $flags) };

    my sub TLN_SetSpritePicture(int32, int32) returns Pointer is native('Tilengine') { * };
    method SetSpritePicture(int32 $nsprite, int32 $entry) { TLN_SetSpritePicture($nsprite, $entry) };

    my sub TLN_SetSpriteAnimation(int32, int32, Pointer, int32) returns Pointer is native('Tilengine') { * };
    method SetSpriteAnimation(int32 $index, int32 $nlayer, Pointer $sequence, int32 $loop) { TLN_SetSpriteAnimation($index, $nlayer, $sequence, $loop) };

    my sub TLN_GetAnimationState(int32) returns bool is native('Tilengine') { * };
    method GetAnimationState(int32 $index) { TLN_GetAnimationState($index) };

    my sub TLN_DisableAnimation(int32) returns bool is native('Tilengine') { * };
    method DisableAnimation(int32 $index) { TLN_DisableAnimation($index) };

    my sub TLN_SetSpritePosition(int32, int32, int32) returns Pointer is native('Tilengine') { * };
    method SetSpritePosition(int32 $nsprite, int32 $x, int32 $y) { TLN_SetSpritePosition($nsprite, $x, $y) };

    my sub TLN_FindSequence(Pointer, Str) returns Pointer is native('Tilengine') { * };
    method FindSequence(Pointer $sp, Str $name) { TLN_FindSequence($sp, $name) };

    my sub TLN_GetLayerPalette(int32) returns Pointer is native('Tilengine') { * };
    method GetLayerPalette(int32 $nlayer) { TLN_GetLayerPalette($nlayer) };

    my sub TLN_SetPaletteAnimation(int32, Pointer, Pointer, bool) is native('Tilengine') { * };
    method SetPaletteAnimation(int32 $index, Pointer $palette, Pointer $sequence, bool $blend) { TLN_SetPaletteAnimation($index, $palette, $sequence, $blend) };

    sub TLN_SetRasterCallback(&callback (Int)) is native('Tilengine') { * };
    #method SetRasterCallback(&callback (Int)) { TLN_SetRasterCallback(&callback) };

    my sub TLN_ProcessWindow() returns bool is native('Tilengine') { * };
    method ProcessWindow() { TLN_ProcessWindow() };

    my sub TLN_GetInput(int32) returns bool is native('Tilengine') { * };
    method GetInput(int32 $input) { TLN_GetInput($input) };
    
    my sub TLN_BeginWindowFrame(int32) is native('Tilengine') { * };
    method BeginWindowFrame(int32 $time) { TLN_BeginWindowFrame($time) };
    
    my sub TLN_SetBGColor(uint8, uint8, uint8) is native('Tilengine') { * };
    method SetBGColor(uint8 $r, uint8 $g, uint8 $b) { TLN_SetBGColor($r, $g, $b) };

    my sub TLN_DrawFrame(int32) is export is native('Tilengine') { * };
    method DrawFrame(int32 $time) { TLN_DrawFrame($time) };

    my sub TLN_DrawNextScanline() returns bool is native('Tilengine') { * };
    method DrawNextScanline() { TLN_DrawNextScanline() };

    my sub TLN_EndWindowFrame() is native('Tilengine') { * };
    method EndWindowFrame() { TLN_EndWindowFrame() };

    my sub TLN_DeleteTileset(Pointer) returns bool is native('Tilengine') { * };
    method DeleteTileset(Pointer $tileset) { TLN_DeleteTileset($tileset) };

    my sub TLN_DeleteTilemap(Pointer) returns bool is native('Tilengine') { * };
    method DeleteTilemap(Pointer $tilemap) { TLN_DeleteTilemap($tilemap) };

    my sub TLN_DeleteSequencePack(Pointer) returns bool is native('Tilengine') { * };
    method DeleteSequencePack(Pointer $sp) { TLN_DeleteSequencePack($sp) };

    my sub TLN_DeleteWindow() is native('Tilengine') { * };
    method DeleteWindow() { TLN_DeleteWindow() };

    my sub TLN_Deinit() is native('Tilengine') { * };
    method Deinit() { TLN_Deinit() };

}

=finish
