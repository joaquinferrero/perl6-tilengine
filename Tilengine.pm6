use v6;
unit module Game::Engine::Tilengine:ver<2017.3.23.21.25>:auth<Joaquin Ferrero (jferrero@gmail.com)>;

use NativeCall;

### CreateWindow flags. Can be none or a combination of the following:
#enum TLN_WindowFlags is export (
#    CWF_FULLSCREEN => 1+<0,    # create a fullscreen window
#    CWF_VSYNC      => 1+<1,    # sync frame updates with vertical retrace
#    CWF_S1         => 1+<2,    # create a window the same size as the framebuffer
#    CWF_S2         => 2+<2,    # create a window 2x the size the framebuffer
#    CWF_S3         => 3+<2,    # create a window 3x the size the framebuffer
#    CWF_S4         => 4+<2,    # create a window 4x the size the framebuffer
#    CWF_S5         => 5+<2,    # create a window 5x the size the framebuffer
#);

# Tile description
class Tile is repr('CStruct') is export  {
    has uint16         $.index          is rw;    # tile index
    has uint16         $.flags          is rw;    # attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY)
}


class TLN_Tileset      is repr('CPointer') is export { }    # Opaque tileset reference
class TLN_Tilemap      is repr('CPointer') is export { }    # Opaque tilemap reference
class TLN_Spriteset    is repr('CPointer') is export { }    # Opaque sspriteset reference
class TLN_Sequence     is repr('CPointer') is export { }    # Opaque sequence reference
class TLN_SequencePack is repr('CPointer') is export { }    # Opaque sequence pack reference
class TLN_Palette      is repr('CPointer') is export { }    # Opaque palette reference

# TODO constantes: como hacer que estén dentro del espacio de nombres de la clase

class Tilengine is export {
    # CreateWindow flags. Can be none or a combination of the following:
    method CWF_FULLSCREEN { 1+<0 }	# create a fullscreen window
    method CWF_VSYNC      { 1+<1 }	# sync frame updates with vertical retrace
    method CWF_S1         { 1+<2 }	# create a window the same size as the framebuffer
    method CWF_S2         { 2+<2 }	# create a window 2x the size the framebuffer
    method CWF_S3         { 3+<2 }	# create a window 3x the size the framebuffer
    method CWF_S4         { 4+<2 }	# create a window 4x the size the framebuffer
    method CWF_S5         { 5+<2 }	# create a window 5x the size the framebuffer

    # tile/sprite flags. Can be none or a combination of the following:
    method FLAG_NONE      { 0       }	# no flags
    method FLAG_FLIPX     { 1+<(15) }	# horizontal flip
    method FLAG_FLIPY     { 1+<(14) }	# vertical flip
    method FLAG_ROTATE    { 1+<(13) }	# row/column flip (unsupported, Tiled compatibility)
    method FLAG_PRIORITY  { 1+<(12) }	# tile goes in front of sprite layer

    # Standard inputs. Must be one of these and are mutually exclusive:
    method INPUT_NONE     { 0 }		# no input
    method INPUT_UP       { 1 }		# up direction
    method INPUT_DOWN     { 2 }		# down direction
    method INPUT_LEFT     { 3 }		# left direction
    method INPUT_RIGHT    { 4 }		# right direction
    method INPUT_A        { 5 }		# first action button
    method INPUT_B        { 6 }		# second action button
    method INPUT_C        { 7 }		# third action button
    method INPUT_D        { 8 }		# fourth action button

    # bool TLN_Init (int hres, int vres, int numlayers, int numsprites, int numanimations);
    my sub TLN_Init(int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * }
    method Init(int32 $hres, int32 $vres, int32 $numlayers, int32 $numsprites, int32 $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) }

    # bool TLN_CreateWindow (Str overlay, TLN_WindowFlags flags);
    my sub TLN_CreateWindow(Str, uint32) returns bool is native('Tilengine') { * }
    #method CreateWindow(Str $overlay, TLN_WindowFlags $flags) { TLN_CreateWindow($overlay, $flags) }
    method CreateWindow(Str $overlay, uint32 $flags) { TLN_CreateWindow($overlay, $flags) }

    # TLN_Tileset TLN_LoadTileset (Str filename);
    my sub TLN_LoadTileset(Str) returns Pointer[TLN_Tileset] is native('Tilengine') { * }
    method LoadTileset(Str $filename) { TLN_LoadTileset($filename) }

    # TLN_Tilemap TLN_LoadTilemap (Str filename, Str layername);
    my sub TLN_LoadTilemap(Str, Str) returns Pointer[TLN_Tilemap] is native('Tilengine') { * }
    method LoadTilemap(Str $filename, Str $layername) { TLN_LoadTilemap($filename, $layername) }

    # bool TLN_SetLayer (int nlayer, TLN_Tileset tileset, TLN_Tilemap tilemap);
    my sub TLN_SetLayer(int32, Pointer[TLN_Tileset], Pointer[TLN_Tilemap]) returns bool is native('Tilengine') { * }
    method SetLayer(int32 $nlayer, Pointer[TLN_Tileset] $tileset, Pointer[TLN_Tilemap] $tilemap) { TLN_SetLayer($nlayer, $tileset, $tilemap) }

    # bool TLN_SetLayerPosition (int nlayer, int hstart, int vstart);
    my sub TLN_SetLayerPosition(int32, int32, int32) returns bool is native('Tilengine') { * }
    method SetLayerPosition(int32 $nlayer, int32 $hstart, int32 $vstart) { TLN_SetLayerPosition($nlayer, $hstart, $vstart) }

    # bool TLN_DeleteTileset (TLN_Tileset tileset);
    my sub TLN_DeleteTileset(Pointer[TLN_Tileset]) returns bool is native('Tilengine') { * }
    method DeleteTileset(Pointer[TLN_Tileset] $tileset) { TLN_DeleteTileset($tileset) }

    # bool TLN_DeleteTilemap (TLN_Tilemap tilemap);
    my sub TLN_DeleteTilemap(Pointer[TLN_Tilemap]) returns bool is native('Tilengine') { * }
    method DeleteTilemap(Pointer[TLN_Tilemap] $tilemap) { TLN_DeleteTilemap($tilemap) }

    # void TLN_SetBGColor (uint8 r, uint8 g, uint8 b);
    my sub TLN_SetBGColor(uint8, uint8, uint8)  is native('Tilengine') { * }
    method SetBGColor(uint8 $r, uint8 $g, uint8 $b) { TLN_SetBGColor($r, $g, $b) }

    # void TLN_SetLoadPath (Str path);
    my sub TLN_SetLoadPath(Str)  is native('Tilengine') { * }
    method SetLoadPath(Str $path) { TLN_SetLoadPath($path) }

    # TLN_Spriteset TLN_LoadSpriteset (Str name);
    my sub TLN_LoadSpriteset(Str) returns Pointer[TLN_Spriteset] is native('Tilengine') { * }
    method LoadSpriteset(Str $name) { TLN_LoadSpriteset($name) }

    # bool TLN_SetSpriteSet (int nsprite, TLN_Spriteset spriteset);
    my sub TLN_SetSpriteSet(int32, Pointer[TLN_Spriteset]) returns bool is native('Tilengine') { * }
    method SetSpriteSet(int32 $nsprite, Pointer[TLN_Spriteset] $spriteset) { TLN_SetSpriteSet($nsprite, $spriteset) }

    # bool TLN_SetSpritePicture (int nsprite, int entry);
    my sub TLN_SetSpritePicture(int32, int32) returns bool is native('Tilengine') { * }
    method SetSpritePicture(int32 $nsprite, int32 $entry) { TLN_SetSpritePicture($nsprite, $entry) }

    # bool TLN_SetSpritePosition (int nsprite, int x, int y);
    my sub TLN_SetSpritePosition(int32, int32, int32) returns bool is native('Tilengine') { * }
    method SetSpritePosition(int32 $nsprite, int32 $x, int32 $y) { TLN_SetSpritePosition($nsprite, $x, $y) }

    # TLN_SequencePack TLN_LoadSequencePack (Str filename);
    my sub TLN_LoadSequencePack(Str) returns Pointer[TLN_SequencePack] is native('Tilengine') { * }
    method LoadSequencePack(Str $filename) { TLN_LoadSequencePack($filename) }

    # TLN_Sequence TLN_FindSequence (TLN_SequencePack sp, Str name);
    my sub TLN_FindSequence(Pointer[TLN_SequencePack], Str) returns Pointer[TLN_Sequence] is native('Tilengine') { * }
    method FindSequence(Pointer[TLN_SequencePack] $sp, Str $name) { TLN_FindSequence($sp, $name) }

    # bool TLN_SetTilesetAnimation (int index, int nlayer, TLN_Sequence sequence);
    my sub TLN_SetTilesetAnimation(int32, int32, Pointer[TLN_Sequence]) returns bool is native('Tilengine') { * }
    method SetTilesetAnimation(int32 $index, int32 $nlayer, Pointer[TLN_Sequence] $sequence) { TLN_SetTilesetAnimation($index, $nlayer, $sequence) }

    # bool TLN_SetSpriteAnimation (int index, int nsprite, TLN_Sequence sequence, int loop);
    my sub TLN_SetSpriteAnimation(int32, int32, Pointer[TLN_Sequence], int32) returns bool is native('Tilengine') { * }
    method SetSpriteAnimation(int32 $index, int32 $nsprite, Pointer[TLN_Sequence] $sequence, int32 $loop) { TLN_SetSpriteAnimation($index, $nsprite, $sequence, $loop) }

    # void TLN_DrawFrame (int time);
    my sub TLN_DrawFrame(int32)  is native('Tilengine') { * }
    method DrawFrame(int32 $time) { TLN_DrawFrame($time) }

    # void TLN_Deinit (void);
    my sub TLN_Deinit()  is native('Tilengine') { * }
    method Deinit( ) { TLN_Deinit() }

    # bool TLN_DeleteSequencePack (TLN_SequencePack sp);
    my sub TLN_DeleteSequencePack(Pointer[TLN_SequencePack]) returns bool is native('Tilengine') { * }
    method DeleteSequencePack(Pointer[TLN_SequencePack] $sp) { TLN_DeleteSequencePack($sp) }

    # void TLN_DeleteWindow (void);
    my sub TLN_DeleteWindow()  is native('Tilengine') { * }
    method DeleteWindow( ) { TLN_DeleteWindow() }

    # bool TLN_ProcessWindow (void);
    my sub TLN_ProcessWindow() returns bool is native('Tilengine') { * }
    method ProcessWindow( ) { TLN_ProcessWindow() }

    # bool TLN_GetInput (TLN_Input id);
    my sub TLN_GetInput(int32) returns bool is native('Tilengine') { * }
    method GetInput(int32 $id) { TLN_GetInput($id) }

    # bool TLN_ConfigSprite (int nsprite, TLN_Spriteset spriteset, TLN_TileFlags flags);
    my sub TLN_ConfigSprite(int32, Pointer[TLN_Spriteset], int32) returns bool is native('Tilengine') { * }
    method ConfigSprite(int32 $nsprite, Pointer[TLN_Spriteset] $spriteset, int32 $flags) { TLN_ConfigSprite($nsprite, $spriteset, $flags) }

    # bool TLN_GetAnimationState (int index);
    my sub TLN_GetAnimationState(int32) returns bool is native('Tilengine') { * }
    method GetAnimationState(int32 $index) { TLN_GetAnimationState($index) }

    # bool TLN_DisableAnimation (int index);
    my sub TLN_DisableAnimation(int32) returns bool is native('Tilengine') { * }
    method DisableAnimation(int32 $index) { TLN_DisableAnimation($index) }

    # bool TLN_GetTilemapTile (TLN_Tilemap tilemap, int row, int col, TLN_Tile tile);
    my sub TLN_GetTilemapTile(Pointer[TLN_Tilemap], int32, int32, Tile) returns bool is native('Tilengine') { * }
    method GetTilemapTile(Pointer[TLN_Tilemap] $tilemap, int32 $row, int32 $col, Tile $tile) { TLN_GetTilemapTile($tilemap, $row, $col, $tile) }

    # bool TLN_SetTilemapTile (TLN_Tilemap tilemap, int row, int col, TLN_Tile tile);
    my sub TLN_SetTilemapTile(Pointer[TLN_Tilemap], int32, int32, Tile) returns bool is native('Tilengine') { * }
    method SetTilemapTile(Pointer[TLN_Tilemap] $tilemap, int32 $row, int32 $col, Tile $tile) { TLN_SetTilemapTile($tilemap, $row, $col, $tile) }

    # TLN_Palette TLN_GetLayerPalette (int nlayer);
    my sub TLN_GetLayerPalette(int32) returns Pointer[TLN_Palette] is native('Tilengine') { * }
    method GetLayerPalette(int32 $nlayer) { TLN_GetLayerPalette($nlayer) }

    # bool TLN_SetPaletteAnimation (int index, TLN_Palette palette, TLN_Sequence sequence, bool blend);
    my sub TLN_SetPaletteAnimation(int32, Pointer[TLN_Palette], Pointer[TLN_Sequence], int32) returns bool is native('Tilengine') { * }
    method SetPaletteAnimation(int32 $index, Pointer[TLN_Palette] $palette, Pointer[TLN_Sequence] $sequence, int32 $blend) { TLN_SetPaletteAnimation($index, $palette, $sequence, $blend) }

    # void TLN_BeginWindowFrame (int time);
    my sub TLN_BeginWindowFrame(int32)  is native('Tilengine') { * }
    method BeginWindowFrame(int32 $time) { TLN_BeginWindowFrame($time) }

    # void TLN_EndWindowFrame (void);
    my sub TLN_EndWindowFrame()  is native('Tilengine') { * }
    method EndWindowFrame( ) { TLN_EndWindowFrame() }

    # bool TLN_DrawNextScanline (void);
    my sub TLN_DrawNextScanline() returns bool is native('Tilengine') { * }
    method DrawNextScanline( ) { TLN_DrawNextScanline() }

}

=finish

# 
# Tilengine - 2D Graphics library with raster effects
# Copyright (c) 2015-2017 Marc Palacios Domènech (megamarc@hotmail.com)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification 
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation 
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 

# 
# ***************************************************************************
# \file
# Tilengine header
# \author Marc Palacios (Megamarc)
# \date Jun 2015
# http://www.tilengine.org
# 
# Main header for Tilengine 2D scanline-based graphics engine
# 
# ****************************************************************************
# 

# Tilengine_core

# Tilengine shared

# bool C++


# version

# fixed point helper

#  
# layer blend modes. Must be one of these and are mutually exclusive:
# 
enum TLN_Blend is export (
    BLEND_NONE                => 0,               # blending disabled
    BLEND_MIX                 => 1,               # color averaging
    BLEND_ADD                 => 2,               # color is always brighter (simulate light effects)
    BLEND_SUB                 => 3,               # color is always darker (simulate shadow effects)
    BLEND_MOD                 => 4,               # color is always darker (simulate shadow effects)
    MAX_BLEND                 => 5,               
);

# Affine transformation parameters
class TLN_Affine is repr('CStruct') is export  {
    has num32          $.angle          is rw;    # rotation in degrees
    has num32          $.dx             is rw;    # horizontal translation
    has num32          $.dy             is rw;    # vertical translation
    has num32          $.sx             is rw;    # horizontal scaling
    has num32          $.sy             is rw;    # vertical scaling
}

# color strip definition
class TLN_ColorStrip is repr('CStruct') is export  {
    has int32          $.delay          is rw;    # time delay between frames
    has uint8          $.first          is rw;    # index of first color to cycle
    has uint8          $.count          is rw;    # number of colors in the cycle
    has uint8          $.dir            is rw;    # direction: 0=descending, 1=ascending
}

# Basic rectangle
class TLN_Rect is repr('CStruct') is export  {
    has int32          $.x              is rw;    # horizontal position
    has int32          $.y              is rw;    # vertical position
    has int32          $.w              is rw;    # width
    has int32          $.h              is rw;    # height
}

# Sprite information
class TLN_SpriteInfo is repr('CStruct') is export  {
    has int32          $.offset         is rw;    # internal use
    has int32          $.w              is rw;    # width of sprite
    has int32          $.h              is rw;    # height of sprite
}

# Tile information in screen coordinates
class TLN_TileInfo is repr('CStruct') is export  {
    has uint16         $.index          is rw;    # tile index
    has uint16         $.flags          is rw;    # attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY)
    has int32          $.row            is rw;    # row number in the tilemap
    has int32          $.col            is rw;    # col number in the tilemap
    has int32          $.xoffset        is rw;    # horizontal position inside the title
    has int32          $.yoffset        is rw;    # vertical position inside the title
    has uint8          $.color          is rw;    # color index at collision point
}

class TLN_Tile is Tile is export { }              # Tile reference
class TLN_Bitmap       is repr('CPointer') { }    # Opaque bitmap reference
class TLN_Cycle        is repr('CPointer') { }    # Opaque color cycle reference

enum TLN_Input is export (
);

# Error codes
enum TLN_Error is export (
    TLN_ERR_OK                => 0,               # No error
    TLN_ERR_OUT_OF_MEMORY     => 1,               # Not enough memory
    TLN_ERR_IDX_LAYER         => 2,               # Layer index out of range
    TLN_ERR_IDX_SPRITE        => 3,               # Sprite index out of range
    TLN_ERR_IDX_ANIMATION     => 4,               # Animation index out of range
    TLN_ERR_IDX_PICTURE       => 5,               # Picture or tile index out of range
    TLN_ERR_REF_TILESET       => 6,               # Invalid TLN_Tileset reference
    TLN_ERR_REF_TILEMAP       => 7,               # Invalid TLN_Tilemap reference
    TLN_ERR_REF_SPRITESET     => 8,               # Invalid TLN_Spriteset reference
    TLN_ERR_REF_PALETTE       => 9,               # Invalid TLN_Palette reference
    TLN_ERR_REF_SEQUENCE      => 10,              # Invalid TLN_SequencePack reference
    TLN_ERR_REF_SEQPACK       => 11,              # Invalid TLN_Sequence reference
    TLN_ERR_REF_BITMAP        => 12,              # Invalid TLN_Bitmap reference
    TLN_ERR_NULL_POINTER      => 13,              # Null pointer as argument
    TLN_ERR_FILE_NOT_FOUND    => 14,              # Resource file not found
    TLN_ERR_WRONG_FORMAT      => 15,              # Resource file has invalid format
    TLN_ERR_WRONG_SIZE        => 16,              # A width or height parameter is invalid
    TLN_ERR_UNSUPPORTED       => 17,              # Unsupported function
    TLN_MAX_ERR               => 18,              
);

# 
# \anchor group_setup
# \name Setup
# Basic setup and management
# bool TLN_InitBPP (int hres, int vres, int bpp, int numlayers, int numsprites, int numanimations);
my sub TLN_InitBPP(int32, int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * }
method InitBPP(int32 $hres, int32 $vres, int32 $bpp, int32 $numlayers, int32 $numsprites, int32 $numanimations) { TLN_InitBPP($hres, $vres, $bpp, $numlayers, $numsprites, $numanimations) }

# int TLN_GetWidth (void);
my sub TLN_GetWidth() returns int32 is native('Tilengine') { * }
method GetWidth( ) { TLN_GetWidth() }

# int TLN_GetHeight (void);
my sub TLN_GetHeight() returns int32 is native('Tilengine') { * }
method GetHeight( ) { TLN_GetHeight() }

# int TLN_GetBPP (void);
my sub TLN_GetBPP() returns int32 is native('Tilengine') { * }
method GetBPP( ) { TLN_GetBPP() }

# uint32 TLN_GetNumObjects (void);
my sub TLN_GetNumObjects() returns uint32 is native('Tilengine') { * }
method GetNumObjects( ) { TLN_GetNumObjects() }

# uint32 TLN_GetUsedMemory (void);
my sub TLN_GetUsedMemory() returns uint32 is native('Tilengine') { * }
method GetUsedMemory( ) { TLN_GetUsedMemory() }

# uint32 TLN_GetVersion (void);
my sub TLN_GetVersion() returns uint32 is native('Tilengine') { * }
method GetVersion( ) { TLN_GetVersion() }

# int TLN_GetNumLayers (void);
my sub TLN_GetNumLayers() returns int32 is native('Tilengine') { * }
method GetNumLayers( ) { TLN_GetNumLayers() }

# int TLN_GetNumSprites (void);
my sub TLN_GetNumSprites() returns int32 is native('Tilengine') { * }
method GetNumSprites( ) { TLN_GetNumSprites() }

# bool TLN_SetBGBitmap (TLN_Bitmap bitmap);
my sub TLN_SetBGBitmap(Pointer) returns bool is native('Tilengine') { * }
method SetBGBitmap(Pointer $bitmap) { TLN_SetBGBitmap($bitmap) }

# bool TLN_SetBGPalette (TLN_Palette palette);
my sub TLN_SetBGPalette(Pointer) returns bool is native('Tilengine') { * }
method SetBGPalette(Pointer $palette) { TLN_SetBGPalette($palette) }

# void TLN_SetRasterCallback (void (*callback)(int));
my sub TLN_SetRasterCallback(&callback (int32))  is native('Tilengine') { * }
method SetRasterCallback(Pointer $callback) { TLN_SetRasterCallback($callback) }

# void TLN_SetRenderTarget (Pointer data, int pitch);
my sub TLN_SetRenderTarget(Pointer, int32)  is native('Tilengine') { * }
method SetRenderTarget(Pointer $data, int32 $pitch) { TLN_SetRenderTarget($data, $pitch) }

# void TLN_UpdateFrame (int time);
my sub TLN_UpdateFrame(int32)  is native('Tilengine') { * }
method UpdateFrame(int32 $time) { TLN_UpdateFrame($time) }

# void TLN_BeginFrame (int time);
my sub TLN_BeginFrame(int32)  is native('Tilengine') { * }
method BeginFrame(int32 $time) { TLN_BeginFrame($time) }



# 
# \anchor group_errors
# \name Errors
# Error handling
# void TLN_SetLastError (TLN_Error error);
my sub TLN_SetLastError(int32)  is native('Tilengine') { * }
method SetLastError(int32 $error) { TLN_SetLastError($error) }

# TLN_Error TLN_GetLastError (void);
my sub TLN_GetLastError() returns int32 is native('Tilengine') { * }
method GetLastError( ) { TLN_GetLastError() }

# Str TLN_GetErrorString (TLN_Error error);
my sub TLN_GetErrorString(int32) returns Str is native('Tilengine') { * }
method GetErrorString(int32 $error) { TLN_GetErrorString($error) }


# 
# \anchor group_windowing
# \name Windowing
# Built-in window and input management
# bool TLN_CreateWindowThread (Str overlay, TLN_WindowFlags flags);
my sub TLN_CreateWindowThread(Str, int32) returns bool is native('Tilengine') { * }
method CreateWindowThread(Str $overlay, int32 $flags) { TLN_CreateWindowThread($overlay, $flags) }

# void TLN_SetWindowTitle (Str title);
my sub TLN_SetWindowTitle(Str)  is native('Tilengine') { * }
method SetWindowTitle(Str $title) { TLN_SetWindowTitle($title) }

# bool TLN_IsWindowActive (void);
my sub TLN_IsWindowActive() returns bool is native('Tilengine') { * }
method IsWindowActive( ) { TLN_IsWindowActive() }

# int TLN_GetLastInput (void);
my sub TLN_GetLastInput() returns int32 is native('Tilengine') { * }
method GetLastInput( ) { TLN_GetLastInput() }

# void TLN_WaitRedraw (void);
my sub TLN_WaitRedraw()  is native('Tilengine') { * }
method WaitRedraw( ) { TLN_WaitRedraw() }

# void TLN_EnableBlur (bool mode);
my sub TLN_EnableBlur(Pointer)  is native('Tilengine') { * }
method EnableBlur(Pointer $mode) { TLN_EnableBlur($mode) }

# void TLN_Delay (uint32 msecs);
my sub TLN_Delay(Pointer)  is native('Tilengine') { * }
method Delay(Pointer $msecs) { TLN_Delay($msecs) }

# uint32 TLN_GetTicks (void);
my sub TLN_GetTicks() returns uint32 is native('Tilengine') { * }
method GetTicks( ) { TLN_GetTicks() }



# 
# \anchor group_spriteset
# \name Spritesets
# Spriteset resources management for sprites
# TLN_Spriteset TLN_CreateSpriteset (int entries, TLN_Rect* rects, Pointer data, int width, int height, int pitch, TLN_Palette palette);
my sub TLN_CreateSpriteset(int32, Pointer, Pointer, int32, int32, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateSpriteset(int32 $entries, Pointer $rects, Pointer $data, int32 $width, int32 $height, int32 $pitch, Pointer $palette) { TLN_CreateSpriteset($entries, $rects, $data, $width, $height, $pitch, $palette) }

# TLN_Spriteset TLN_CloneSpriteset (TLN_Spriteset src);
my sub TLN_CloneSpriteset(Pointer) returns Pointer is native('Tilengine') { * }
method CloneSpriteset(Pointer $src) { TLN_CloneSpriteset($src) }

# bool TLN_GetSpriteInfo (TLN_Spriteset spriteset, int entry, TLN_SpriteInfo* info);
my sub TLN_GetSpriteInfo(Pointer, int32, Pointer) returns bool is native('Tilengine') { * }
method GetSpriteInfo(Pointer $spriteset, int32 $entry, Pointer $info) { TLN_GetSpriteInfo($spriteset, $entry, $info) }

# TLN_Palette TLN_GetSpritesetPalette (TLN_Spriteset spriteset);
my sub TLN_GetSpritesetPalette(Pointer) returns Pointer is native('Tilengine') { * }
method GetSpritesetPalette(Pointer $spriteset) { TLN_GetSpritesetPalette($spriteset) }

# bool TLN_DeleteSpriteset (TLN_Spriteset Spriteset);
my sub TLN_DeleteSpriteset(Pointer) returns bool is native('Tilengine') { * }
method DeleteSpriteset(Pointer $Spriteset) { TLN_DeleteSpriteset($Spriteset) }


# 
# \anchor group_tileset
# \name Tilesets
# Tileset resources management for background layers
# TLN_Tileset TLN_CreateTileset (int numtiles, int width, int height, TLN_Palette palette);
my sub TLN_CreateTileset(int32, int32, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateTileset(int32 $numtiles, int32 $width, int32 $height, Pointer $palette) { TLN_CreateTileset($numtiles, $width, $height, $palette) }

# TLN_Tileset TLN_CloneTileset (TLN_Tileset src);
my sub TLN_CloneTileset(Pointer) returns Pointer is native('Tilengine') { * }
method CloneTileset(Pointer $src) { TLN_CloneTileset($src) }

# bool TLN_SetTilesetPixels (TLN_Tileset tileset, int entry, Pointer srcdata, int srcpitch);
my sub TLN_SetTilesetPixels(Pointer, int32, Pointer, int32) returns bool is native('Tilengine') { * }
method SetTilesetPixels(Pointer $tileset, int32 $entry, Pointer $srcdata, int32 $srcpitch) { TLN_SetTilesetPixels($tileset, $entry, $srcdata, $srcpitch) }

# bool TLN_CopyTile (TLN_Tileset tileset, int src, int dst);
my sub TLN_CopyTile(Pointer, int32, int32) returns bool is native('Tilengine') { * }
method CopyTile(Pointer $tileset, int32 $src, int32 $dst) { TLN_CopyTile($tileset, $src, $dst) }

# int TLN_GetTileWidth (TLN_Tileset tileset);
my sub TLN_GetTileWidth(Pointer) returns int32 is native('Tilengine') { * }
method GetTileWidth(Pointer $tileset) { TLN_GetTileWidth($tileset) }

# int TLN_GetTileHeight (TLN_Tileset tileset);
my sub TLN_GetTileHeight(Pointer) returns int32 is native('Tilengine') { * }
method GetTileHeight(Pointer $tileset) { TLN_GetTileHeight($tileset) }

# TLN_Palette TLN_GetTilesetPalette (TLN_Tileset tileset);
my sub TLN_GetTilesetPalette(Pointer) returns Pointer is native('Tilengine') { * }
method GetTilesetPalette(Pointer $tileset) { TLN_GetTilesetPalette($tileset) }

# 
# \anchor group_tilemap
# \name Tilemaps 
# Tilemap resources management for background layers
# TLN_Tilemap TLN_CreateTilemap (int rows, int cols, TLN_Tile tiles);
my sub TLN_CreateTilemap(int32, int32, Tile) returns Pointer is native('Tilengine') { * }
method CreateTilemap(int32 $rows, int32 $cols, Tile $tiles) { TLN_CreateTilemap($rows, $cols, $tiles) }

# TLN_Tilemap TLN_CloneTilemap (TLN_Tilemap src);
my sub TLN_CloneTilemap(Pointer) returns Pointer is native('Tilengine') { * }
method CloneTilemap(Pointer $src) { TLN_CloneTilemap($src) }

# int TLN_GetTilemapRows (TLN_Tilemap tilemap);
my sub TLN_GetTilemapRows(Pointer) returns int32 is native('Tilengine') { * }
method GetTilemapRows(Pointer $tilemap) { TLN_GetTilemapRows($tilemap) }

# int TLN_GetTilemapCols (TLN_Tilemap tilemap);
my sub TLN_GetTilemapCols(Pointer) returns int32 is native('Tilengine') { * }
method GetTilemapCols(Pointer $tilemap) { TLN_GetTilemapCols($tilemap) }

# bool TLN_CopyTiles (TLN_Tilemap src, int srcrow, int srccol, int rows, int cols, TLN_Tilemap dst, int dstrow, int dstcol);
my sub TLN_CopyTiles(Pointer, int32, int32, int32, int32, Pointer, int32, int32) returns bool is native('Tilengine') { * }
method CopyTiles(Pointer $src, int32 $srcrow, int32 $srccol, int32 $rows, int32 $cols, Pointer $dst, int32 $dstrow, int32 $dstcol) { TLN_CopyTiles($src, $srcrow, $srccol, $rows, $cols, $dst, $dstrow, $dstcol) }


# 
# \anchor group_palette
# \name Palettes
# Color palette resources management for sprites and background layers
# TLN_Palette TLN_CreatePalette (int entries);
my sub TLN_CreatePalette(int32) returns Pointer is native('Tilengine') { * }
method CreatePalette(int32 $entries) { TLN_CreatePalette($entries) }

# TLN_Palette TLN_LoadPalette (Str filename);
my sub TLN_LoadPalette(Str) returns Pointer is native('Tilengine') { * }
method LoadPalette(Str $filename) { TLN_LoadPalette($filename) }

# TLN_Palette TLN_ClonePalette (TLN_Palette src);
my sub TLN_ClonePalette(Pointer) returns Pointer is native('Tilengine') { * }
method ClonePalette(Pointer $src) { TLN_ClonePalette($src) }

# bool TLN_SetPaletteColor (TLN_Palette palette, int color, uint8 r, uint8 g, uint8 b);
my sub TLN_SetPaletteColor(Pointer, int32, uint8, uint8, uint8) returns bool is native('Tilengine') { * }
method SetPaletteColor(Pointer $palette, int32 $color, uint8 $r, uint8 $g, uint8 $b) { TLN_SetPaletteColor($palette, $color, $r, $g, $b) }

# bool TLN_MixPalettes (TLN_Palette src1, TLN_Palette src2, TLN_Palette dst, uint8 factor);
my sub TLN_MixPalettes(Pointer, Pointer, Pointer, uint8) returns bool is native('Tilengine') { * }
method MixPalettes(Pointer $src1, Pointer $src2, Pointer $dst, uint8 $factor) { TLN_MixPalettes($src1, $src2, $dst, $factor) }

# Pointer TLN_GetPaletteData (TLN_Palette palette, int index);
my sub TLN_GetPaletteData(Pointer, int32) returns Pointer is native('Tilengine') { * }
method GetPaletteData(Pointer $palette, int32 $index) { TLN_GetPaletteData($palette, $index) }

# bool TLN_DeletePalette (TLN_Palette palette);
my sub TLN_DeletePalette(Pointer) returns bool is native('Tilengine') { * }
method DeletePalette(Pointer $palette) { TLN_DeletePalette($palette) }


# 
# \anchor group_bitmap
# \name Bitmaps 
# Bitmap management
# TLN_Bitmap TLN_CreateBitmap (int width, int height, int bpp);
my sub TLN_CreateBitmap(int32, int32, int32) returns Pointer is native('Tilengine') { * }
method CreateBitmap(int32 $width, int32 $height, int32 $bpp) { TLN_CreateBitmap($width, $height, $bpp) }

# TLN_Bitmap TLN_LoadBitmap (Str filename);
my sub TLN_LoadBitmap(Str) returns Pointer is native('Tilengine') { * }
method LoadBitmap(Str $filename) { TLN_LoadBitmap($filename) }

# TLN_Bitmap TLN_CloneBitmap (TLN_Bitmap src);
my sub TLN_CloneBitmap(Pointer) returns Pointer is native('Tilengine') { * }
method CloneBitmap(Pointer $src) { TLN_CloneBitmap($src) }

# Pointer TLN_GetBitmapPtr (TLN_Bitmap bitmap, int x, int y);
my sub TLN_GetBitmapPtr(Pointer, int32, int32) returns Pointer is native('Tilengine') { * }
method GetBitmapPtr(Pointer $bitmap, int32 $x, int32 $y) { TLN_GetBitmapPtr($bitmap, $x, $y) }

# int TLN_GetBitmapWidth (TLN_Bitmap bitmap);
my sub TLN_GetBitmapWidth(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapWidth(Pointer $bitmap) { TLN_GetBitmapWidth($bitmap) }

# int TLN_GetBitmapHeight (TLN_Bitmap bitmap);
my sub TLN_GetBitmapHeight(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapHeight(Pointer $bitmap) { TLN_GetBitmapHeight($bitmap) }

# int TLN_GetBitmapDepth (TLN_Bitmap bitmap);
my sub TLN_GetBitmapDepth(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapDepth(Pointer $bitmap) { TLN_GetBitmapDepth($bitmap) }

# int TLN_GetBitmapPitch (TLN_Bitmap bitmap);
my sub TLN_GetBitmapPitch(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapPitch(Pointer $bitmap) { TLN_GetBitmapPitch($bitmap) }

# TLN_Palette TLN_GetBitmapPalette (TLN_Bitmap bitmap);
my sub TLN_GetBitmapPalette(Pointer) returns Pointer is native('Tilengine') { * }
method GetBitmapPalette(Pointer $bitmap) { TLN_GetBitmapPalette($bitmap) }

# bool TLN_SetBitmapPalette (TLN_Bitmap bitmap, TLN_Palette palette);
my sub TLN_SetBitmapPalette(Pointer, Pointer) returns bool is native('Tilengine') { * }
method SetBitmapPalette(Pointer $bitmap, Pointer $palette) { TLN_SetBitmapPalette($bitmap, $palette) }

# bool TLN_DeleteBitmap (TLN_Bitmap bitmap);
my sub TLN_DeleteBitmap(Pointer) returns bool is native('Tilengine') { * }
method DeleteBitmap(Pointer $bitmap) { TLN_DeleteBitmap($bitmap) }


# 
# \anchor group_layer
# \name Layers
# Background layers management
# bool TLN_SetLayerPalette (int nlayer, TLN_Palette palette);
my sub TLN_SetLayerPalette(int32, Pointer) returns bool is native('Tilengine') { * }
method SetLayerPalette(int32 $nlayer, Pointer $palette) { TLN_SetLayerPalette($nlayer, $palette) }

# bool TLN_SetLayerScaling (int nlayer, float xfactor, float yfactor);
my sub TLN_SetLayerScaling(int32, num32, num32) returns bool is native('Tilengine') { * }
method SetLayerScaling(int32 $nlayer, num32 $xfactor, num32 $yfactor) { TLN_SetLayerScaling($nlayer, $xfactor, $yfactor) }

# bool TLN_SetLayerAffineTransform (int nlayer, TLN_Affine *affine);
my sub TLN_SetLayerAffineTransform(int32, Pointer) returns bool is native('Tilengine') { * }
method SetLayerAffineTransform(int32 $nlayer, Pointer $affine) { TLN_SetLayerAffineTransform($nlayer, $affine) }

# bool TLN_SetLayerTransform (int layer, float angle, float dx, float dy, float sx, float sy);
my sub TLN_SetLayerTransform(int32, num32, num32, num32, num32, num32) returns bool is native('Tilengine') { * }
method SetLayerTransform(int32 $layer, num32 $angle, num32 $dx, num32 $dy, num32 $sx, num32 $sy) { TLN_SetLayerTransform($layer, $angle, $dx, $dy, $sx, $sy) }

# bool TLN_SetLayerBlendMode (int nlayer, TLN_Blend mode, uint8 factor);
my sub TLN_SetLayerBlendMode(int32, int32, uint8) returns bool is native('Tilengine') { * }
method SetLayerBlendMode(int32 $nlayer, int32 $mode, uint8 $factor) { TLN_SetLayerBlendMode($nlayer, $mode, $factor) }

# bool TLN_SetLayerColumnOffset (int nlayer, int* offset);
my sub TLN_SetLayerColumnOffset(int32, Pointer) returns bool is native('Tilengine') { * }
method SetLayerColumnOffset(int32 $nlayer, Pointer $offset) { TLN_SetLayerColumnOffset($nlayer, $offset) }

# bool TLN_ResetLayerMode (int nlayer);
my sub TLN_ResetLayerMode(int32) returns bool is native('Tilengine') { * }
method ResetLayerMode(int32 $nlayer) { TLN_ResetLayerMode($nlayer) }

# bool TLN_DisableLayer (int nlayer);
my sub TLN_DisableLayer(int32) returns bool is native('Tilengine') { * }
method DisableLayer(int32 $nlayer) { TLN_DisableLayer($nlayer) }

# bool TLN_GetLayerTile (int nlayer, int x, int y, TLN_TileInfo* info);
my sub TLN_GetLayerTile(int32, int32, int32, Pointer) returns bool is native('Tilengine') { * }
method GetLayerTile(int32 $nlayer, int32 $x, int32 $y, Pointer $info) { TLN_GetLayerTile($nlayer, $x, $y, $info) }


# 
# \anchor group_sprite
# \name Sprites 
# Sprites management
# bool TLN_SetSpriteFlags (int nsprite, TLN_TileFlags flags);
my sub TLN_SetSpriteFlags(int32, int32) returns bool is native('Tilengine') { * }
method SetSpriteFlags(int32 $nsprite, int32 $flags) { TLN_SetSpriteFlags($nsprite, $flags) }

# bool TLN_SetSpritePalette (int nsprite, TLN_Palette palette);
my sub TLN_SetSpritePalette(int32, Pointer) returns bool is native('Tilengine') { * }
method SetSpritePalette(int32 $nsprite, Pointer $palette) { TLN_SetSpritePalette($nsprite, $palette) }

# bool TLN_SetSpriteBlendMode (int nsprite, TLN_Blend mode, uint8 factor);
my sub TLN_SetSpriteBlendMode(int32, int32, uint8) returns bool is native('Tilengine') { * }
method SetSpriteBlendMode(int32 $nsprite, int32 $mode, uint8 $factor) { TLN_SetSpriteBlendMode($nsprite, $mode, $factor) }

# bool TLN_SetSpriteScaling (int nsprite, float sx, float sy);
my sub TLN_SetSpriteScaling(int32, num32, num32) returns bool is native('Tilengine') { * }
method SetSpriteScaling(int32 $nsprite, num32 $sx, num32 $sy) { TLN_SetSpriteScaling($nsprite, $sx, $sy) }

# bool TLN_ResetSpriteScaling (int nsprite);
my sub TLN_ResetSpriteScaling(int32) returns bool is native('Tilengine') { * }
method ResetSpriteScaling(int32 $nsprite) { TLN_ResetSpriteScaling($nsprite) }

# int TLN_GetSpritePicture (int nsprite);
my sub TLN_GetSpritePicture(int32) returns int32 is native('Tilengine') { * }
method GetSpritePicture(int32 $nsprite) { TLN_GetSpritePicture($nsprite) }

# int TLN_GetAvailableSprite (void);
my sub TLN_GetAvailableSprite() returns int32 is native('Tilengine') { * }
method GetAvailableSprite( ) { TLN_GetAvailableSprite() }

# bool TLN_EnableSpriteCollision (int nsprite, bool enable);
my sub TLN_EnableSpriteCollision(int32, Pointer) returns bool is native('Tilengine') { * }
method EnableSpriteCollision(int32 $nsprite, Pointer $enable) { TLN_EnableSpriteCollision($nsprite, $enable) }

# bool TLN_GetSpriteCollision (int nsprite);
my sub TLN_GetSpriteCollision(int32) returns bool is native('Tilengine') { * }
method GetSpriteCollision(int32 $nsprite) { TLN_GetSpriteCollision($nsprite) }

# bool TLN_DisableSprite (int nsprite);
my sub TLN_DisableSprite(int32) returns bool is native('Tilengine') { * }
method DisableSprite(int32 $nsprite) { TLN_DisableSprite($nsprite) }

# TLN_Palette TLN_GetSpritePalette (int nsprite);
my sub TLN_GetSpritePalette(int32) returns Pointer is native('Tilengine') { * }
method GetSpritePalette(int32 $nsprite) { TLN_GetSpritePalette($nsprite) }


# 
# \anchor group_sequence
# \name Sequences
# Sequence resources management for layer, sprite and palette animations
# TLN_Sequence TLN_CreateSequence (Str name, int delay, int first, int num_frames, int* data);
my sub TLN_CreateSequence(Str, int32, int32, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateSequence(Str $name, int32 $delay, int32 $first, int32 $num_frames, Pointer $data) { TLN_CreateSequence($name, $delay, $first, $num_frames, $data) }

# TLN_Cycle TLN_CreateCycle (Str name, int num_strips, TLN_ColorStrip* strips);
my sub TLN_CreateCycle(Str, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateCycle(Str $name, int32 $num_strips, Pointer $strips) { TLN_CreateCycle($name, $num_strips, $strips) }

# TLN_Sequence TLN_CloneSequence (TLN_Sequence src);
my sub TLN_CloneSequence(Pointer) returns Pointer is native('Tilengine') { * }
method CloneSequence(Pointer $src) { TLN_CloneSequence($src) }

# bool TLN_DeleteSequence (TLN_Sequence sequence);
my sub TLN_DeleteSequence(Pointer) returns bool is native('Tilengine') { * }
method DeleteSequence(Pointer $sequence) { TLN_DeleteSequence($sequence) }


# 
# \anchor group_sequencepack
# \name Sequence packs
# Sequence pack manager for grouping and finding sequences
# TLN_SequencePack TLN_CreateSequencePack (void);
my sub TLN_CreateSequencePack() returns Pointer is native('Tilengine') { * }
method CreateSequencePack( ) { TLN_CreateSequencePack() }

# bool TLN_AddSequenceToPack (TLN_SequencePack sp, TLN_Sequence sequence);
my sub TLN_AddSequenceToPack(Pointer, Pointer) returns bool is native('Tilengine') { * }
method AddSequenceToPack(Pointer $sp, Pointer $sequence) { TLN_AddSequenceToPack($sp, $sequence) }


# 
# \anchor group_animation
# \name Animations 
# Animation engine manager
# bool TLN_SetPaletteAnimationSource (int index, TLN_Palette);
my sub TLN_SetPaletteAnimationSource(int32, Pointer) returns bool is native('Tilengine') { * }
method SetPaletteAnimationSource(int32 $index, Pointer $Pointer) { TLN_SetPaletteAnimationSource($index, $Pointer) }

# bool TLN_SetTilemapAnimation (int index, int nlayer, TLN_Sequence);
my sub TLN_SetTilemapAnimation(int32, int32, Pointer) returns bool is native('Tilengine') { * }
method SetTilemapAnimation(int32 $index, int32 $nlayer, Pointer $Pointer) { TLN_SetTilemapAnimation($index, $nlayer, $Pointer) }

# bool TLN_SetAnimationDelay (int index, int delay);
my sub TLN_SetAnimationDelay(int32, int32) returns bool is native('Tilengine') { * }
method SetAnimationDelay(int32 $index, int32 $delay) { TLN_SetAnimationDelay($index, $delay) }

# int TLN_GetAvailableAnimation (void);
my sub TLN_GetAvailableAnimation() returns int32 is native('Tilengine') { * }
method GetAvailableAnimation( ) { TLN_GetAvailableAnimation() }



