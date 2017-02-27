use v6;
unit module Tilengine1:ver<0.0.1>:auth<Joaquin Ferrero (jferrero@gmail.com)>;

use NativeCall;

class Tile is repr('CStruct') is export {
    has int32 $.index is rw;
    has int32 $.flags is rw;
}

    sub TLN_Init(int32, int32, int32, int32, int32) returns bool is export is native('Tilengine') { * };

    sub TLN_CreateWindow(Str, int32) returns bool is export is native('Tilengine') { * };

    sub TLN_LoadTileset(Str) returns Pointer is export is native('Tilengine') { * };

    sub TLN_SetTilesetAnimation(int32, int32, Pointer) returns Pointer is export is native('Tilengine') { * };

    sub TLN_LoadTilemap(Str, Str) returns Pointer is export is native('Tilengine') { * };

    sub TLN_GetTilemapTile(Pointer, int32, int32, Tile) returns bool is export is native('Tilengine') { * };

    sub TLN_SetTilemapTile(Pointer, int32, int32, Tile) returns bool is export is native('Tilengine') { * };

    sub TLN_SetLayer(int32, Pointer, Pointer) is export is native('Tilengine') { * };

    sub TLN_LoadSequencePack(Str) returns Pointer is export is native('Tilengine') { * };

    sub TLN_SetLoadPath(Str) is export is native('Tilengine') { * };

    sub TLN_LoadSpriteset(Str) returns Pointer is export is native('Tilengine') { * };

    sub TLN_SetSpriteSet(int32, Pointer) returns Pointer is export is native('Tilengine') { * };

    sub TLN_ConfigSprite(int32, Pointer, int32) returns bool is export is native('Tilengine') { * };

    sub TLN_SetSpritePicture(int32, int32) returns Pointer is export is native('Tilengine') { * };

    sub TLN_SetSpriteAnimation(int32, int32, Pointer, int32) returns Pointer is export is native('Tilengine') { * };

    sub TLN_GetAnimationState(int32) returns bool is export is native('Tilengine') { * };

    sub TLN_DisableAnimation(int32) returns bool is export is native('Tilengine') { * };

    sub TLN_SetSpritePosition(int32, int32, int32) returns Pointer is export is native('Tilengine') { * };

    sub TLN_FindSequence(Pointer, Str) returns Pointer is export is native('Tilengine') { * };

    sub TLN_GetLayerPalette(int32) returns Pointer is export is native('Tilengine') { * };

    sub TLN_SetPaletteAnimation(int32, Pointer, Pointer, bool) is export is native('Tilengine') { * };

    sub TLN_ProcessWindow() returns bool is export is native('Tilengine') { * };

    sub TLN_GetInput(int32) returns bool is export is native('Tilengine') { * };
    
    sub TLN_SetLayerPosition(int32, int32, int32) returns bool is export is native('Tilengine') { * };

    sub TLN_BeginWindowFrame(int32) is export is native('Tilengine') { * };
    
    sub TLN_SetBGColor(uint8, uint8, uint8) is export is native('Tilengine') { * };

    sub TLN_DrawFrame(int32) is export is export is native('Tilengine') { * };

    sub TLN_DrawNextScanline() returns bool is export is native('Tilengine') { * };

    sub TLN_EndWindowFrame() is export is native('Tilengine') { * };

    sub TLN_DeleteTileset(Pointer) returns bool is export is native('Tilengine') { * };

    sub TLN_DeleteTilemap(Pointer) returns bool is export is native('Tilengine') { * };

    sub TLN_DeleteSequencePack(Pointer) returns bool is export is native('Tilengine') { * };

    sub TLN_DeleteWindow() is export is native('Tilengine') { * };

    sub TLN_Deinit() is export is native('Tilengine') { * };


=finish
