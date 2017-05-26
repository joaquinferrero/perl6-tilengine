use v6;
unit class Tilengine:ver<117.2.27>:auth<Joaquin Ferrero (jferrero@gmail.com)>;

use NativeCall;

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

constant _TILENGINE_H = '';

# Tilengine_core 
constant TLNAPI = '';

# Tilengine shared 
#constant TLNAPI = __declspec(dllexport);
#constant TLNAPI = __declspec(dllimport);
#constant TLNAPI = __attribute__((visibility("default")));
#constant TLNAPI = '';

constant BYTE = uint8;	# !< 8-bit wide data 
constant WORD = uint16;	# !< 16-bit wide data 
constant DWORD = uint32;	# !< 32-bit wide data 
constant NULL = 0;

# bool C++ 
#constant bool = uint8;		# !< C++ bool type for C language 
#constant false = 0;
#constant true = 1;

# version 
constant TILENGINE_VER_MAJ = 1;
constant TILENGINE_VER_MIN = 10;
constant TILENGINE_VER_REV = 0;
constant TILENGINE_HEADER_VERSION = ((TILENGINE_VER_MAJ+<16) +| (TILENGINE_VER_MIN+<8) +| TILENGINE_VER_REV);

sub BITVAL($n) { (1+<($n)) }

# ! tile/sprite flags. Can be none or a combination of the following: 
enum TLN_TileFlags (
	FLAG_NONE => 0,			# !< no flags 
	FLAG_FLIPX => BITVAL(15),			# !< horizontal flip 
	FLAG_FLIPY => BITVAL(14),			# !< vertical flip 
	FLAG_ROTATE => BITVAL(13),			# !< row/column flip (unsupported, Tiled compatibility) 
	FLAG_PRIORITY => BITVAL(12),			# !< tile goes in front of sprite layer 
);

# fixed point helper 
constant fix_t = int32;
constant FIXED_BITS = 16;
sub float2fix($f) { (fix_t)($f*(1 +< FIXED_BITS)) }
sub int2fix($i) { ((int32)($i) +< FIXED_BITS) }
sub fix2int($f) { ((int32)($f) +> FIXED_BITS) }
sub fix2float($f) { (num32)($f)/(1 +< FIXED_BITS) }

# ! 
# layer blend modes. Must be one of these and are mutually exclusive:
# 
enum TLN_Blend (
	BLEND_NONE => 0,			# !< blending disabled 
	BLEND_MIX => 1,			# !< color averaging 
	BLEND_ADD => 2,			# !< color is always brighter (simulate light effects) 
	BLEND_SUB => 3,			# !< color is always darker (simulate shadow effects) 
	BLEND_MOD => 4,			# !< color is always darker (simulate shadow effects) 
	MAX_BLEND => 5,		
);

# ! Affine transformation parameters 
class TLN_Affine is repr('CStruct') is export  {
	has num32	$.angle	is rw;		# !< rotation in degrees 
	has num32	$.dx	is rw;		# !< horizontal translation 
	has num32	$.dy	is rw;		# !< vertical translation 
	has num32	$.sx	is rw;		# !< horizontal scaling 
	has num32	$.sy	is rw;		# !< vertical scaling 
}

# ! Tile description 
class Tile is repr('CStruct') is export  {
	has WORD	$.index	is rw;		# !< tile index 
	has WORD	$.flags	is rw;		# !< attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY) 
}

# ! color strip definition 
class TLN_ColorStrip is repr('CStruct') is export  {
	has int32	$.delay	is rw;		# !< time delay between frames 
	has BYTE	$.first	is rw;		# !< index of first color to cycle 
	has BYTE	$.count	is rw;		# !< number of colors in the cycle 
	has BYTE	$.dir	is rw;		# !< direction: 0=descending, 1=ascending 
}

# ! Basic rectangle 
class TLN_Rect is repr('CStruct') is export  {
	has int32	$.x	is rw;		# !< horizontal position 
	has int32	$.y	is rw;		# !< vertical position 
	has int32	$.w	is rw;		# !< width 
	has int32	$.h	is rw;		# !< height 
}

# ! Sprite information 
class TLN_SpriteInfo is repr('CStruct') is export  {
	has int32	$.offset	is rw;		# !< internal use 
	has int32	$.w	is rw;		# !< width of sprite 
	has int32	$.h	is rw;		# !< height of sprite 
}

# ! Tile information in screen coordinates 
class TLN_TileInfo is repr('CStruct') is export  {
	has WORD	$.index	is rw;		# !< tile index 
	has WORD	$.flags	is rw;		# !< attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY) 
	has int32	$.row	is rw;		# !< row number in the tilemap 
	has int32	$.col	is rw;		# !< col number in the tilemap 
	has int32	$.xoffset	is rw;		# !< horizontal position inside the title 
	has int32	$.yoffset	is rw;		# !< vertical position inside the title 
	has BYTE	$.color	is rw;		# !< color index at collision point 
}

class TLN_Tile is Pointer is export { }
class TLN_Tileset is Pointer is export { }
class TLN_Tilemap is Pointer is export { }
class TLN_Palette is Pointer is export { }
class TLN_Spriteset is Pointer is export { }
class TLN_Sequence is Pointer is export { }
class TLN_SequencePack is Pointer is export { }
class TLN_Bitmap is Pointer is export { }
class TLN_Cycle is Pointer is export { }
class TLN_SetBGBitmap is Pointer is export { }
class TLN_SetBGPalette is Pointer is export { }

# ! Standard inputs. Must be one of these and are mutually exclusive: 
enum TLN_Input (
	INPUT_NONE => 0,			# !< no input 
	INPUT_UP => 1,			# !< up direction 
	INPUT_DOWN => 2,			# !< down direction 
	INPUT_LEFT => 3,			# !< left direction 
	INPUT_RIGHT => 4,			# !< right direction 
	INPUT_A => 5,			# !< first action button 
	INPUT_B => 6,			# !< second action button 
	INPUT_C => 7,			# !< third action button 
	INPUT_D => 8,			# !< fourth action button 
);

# ! CreateWindow flags. Can be none or a combination of the following: 
enum TLN_WindowFlags (
	CWF_FULLSCREEN => (1+<0),			# !< create a fullscreen window 
	CWF_VSYNC => (1+<1),			# !< sync frame updates with vertical retrace 
	CWF_S1 => (1+<2),			# !< create a window the same size as the framebuffer 
	CWF_S2 => (2+<2),			# !< create a window 2x the size the framebuffer 
	CWF_S3 => (3+<2),			# !< create a window 3x the size the framebuffer 
	CWF_S4 => (4+<2),			# !< create a window 4x the size the framebuffer 
	CWF_S5 => (5+<2),			# !< create a window 5x the size the framebuffer 
);

# ! Error codes 
enum TLN_Error (
	TLN_ERR_OK => 0,			# !< No error 
	TLN_ERR_OUT_OF_MEMORY => 1,			# !< Not enough memory 
	TLN_ERR_IDX_LAYER => 2,			# !< Layer index out of range 
	TLN_ERR_IDX_SPRITE => 3,			# !< Sprite index out of range 
	TLN_ERR_IDX_ANIMATION => 4,			# !< Animation index out of range 
	TLN_ERR_IDX_PICTURE => 5,			# !< Picture or tile index out of range 
	TLN_ERR_REF_TILESET => 6,			# !< Invalid TLN_Tileset reference 
	TLN_ERR_REF_TILEMAP => 7,			# !< Invalid TLN_Tilemap reference 
	TLN_ERR_REF_SPRITESET => 8,			# !< Invalid TLN_Spriteset reference 
	TLN_ERR_REF_PALETTE => 9,			# !< Invalid TLN_Palette reference 
	TLN_ERR_REF_SEQUENCE => 10,			# !< Invalid TLN_SequencePack reference 
	TLN_ERR_REF_SEQPACK => 11,			# !< Invalid TLN_Sequence reference 
	TLN_ERR_REF_BITMAP => 12,			# !< Invalid TLN_Bitmap reference 
	TLN_ERR_NULL_POINTER => 13,			# !< Null pointer as argument 
	TLN_ERR_FILE_NOT_FOUND => 14,			# !< Resource file not found 
	TLN_ERR_WRONG_FORMAT => 15,			# !< Resource file has invalid format 
	TLN_ERR_WRONG_SIZE => 16,			# !< A width or height parameter is invalid 
	TLN_ERR_UNSUPPORTED => 17,			# !< Unsupported function 
	TLN_MAX_ERR => 18,		
);


# 
# \anchor group_setup
# \name Setup
# Basic setup and management
my sub TLN_Init(int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * }
method Init(int32 $hres, int32 $vres, int32 $numlayers, int32 $numsprites, int32 $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) }

my sub TLN_InitBPP(int32, int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * }
method InitBPP(int32 $hres, int32 $vres, int32 $bpp, int32 $numlayers, int32 $numsprites, int32 $numanimations) { TLN_InitBPP($hres, $vres, $bpp, $numlayers, $numsprites, $numanimations) }

my sub TLN_Deinit() is native('Tilengine') { * }
method Deinit() { TLN_Deinit() }

my sub TLN_GetWidth() returns int32 is native('Tilengine') { * }
method GetWidth() { TLN_GetWidth() }

my sub TLN_GetHeight() returns int32 is native('Tilengine') { * }
method GetHeight() { TLN_GetHeight() }

my sub TLN_GetBPP() returns int32 is native('Tilengine') { * }
method GetBPP() { TLN_GetBPP() }

my sub TLN_GetNumObjects() returns DWORD is native('Tilengine') { * }
method GetNumObjects() { TLN_GetNumObjects() }

my sub TLN_GetUsedMemory() returns DWORD is native('Tilengine') { * }
method GetUsedMemory() { TLN_GetUsedMemory() }

my sub TLN_GetVersion() returns DWORD is native('Tilengine') { * }
method GetVersion() { TLN_GetVersion() }

my sub TLN_GetNumLayers() returns int32 is native('Tilengine') { * }
method GetNumLayers() { TLN_GetNumLayers() }

my sub TLN_GetNumSprites() returns int32 is native('Tilengine') { * }
method GetNumSprites() { TLN_GetNumSprites() }

my sub TLN_SetBGColor(BYTE, BYTE, BYTE) is native('Tilengine') { * }
method SetBGColor(BYTE $r, BYTE $g, BYTE $b) { TLN_SetBGColor($r, $g, $b) }

my sub TLN_SetBGBitmap(Pointer) returns bool is native('Tilengine') { * }
method SetBGBitmap(Pointer $bitmap) { TLN_SetBGBitmap($bitmap) }

my sub TLN_SetBGPalette(Pointer) returns bool is native('Tilengine') { * }
method SetBGPalette(Pointer $palette) { TLN_SetBGPalette($palette) }

#my sub TLN_SetRasterCallback( (*callback)(int)) is native('Tilengine') { * }
#method SetRasterCallback( (*callback)(int)) { TLN_SetRasterCallback() }

my sub TLN_SetRenderTarget(Pointer, int32) is native('Tilengine') { * }
method SetRenderTarget(Pointer $data, int32 $pitch) { TLN_SetRenderTarget($data, $pitch) }

my sub TLN_UpdateFrame(int32) is native('Tilengine') { * }
method UpdateFrame(int32 $time) { TLN_UpdateFrame($time) }

my sub TLN_BeginFrame(int32) is native('Tilengine') { * }
method BeginFrame(int32 $time) { TLN_BeginFrame($time) }

my sub TLN_DrawNextScanline() returns bool is native('Tilengine') { * }
method DrawNextScanline() { TLN_DrawNextScanline() }

my sub TLN_SetLoadPath(Str) is native('Tilengine') { * }
method SetLoadPath(Str $path) { TLN_SetLoadPath($path) }



# 
# \anchor group_errors
# \name Errors
# Error handling
my sub TLN_SetLastError(Pointer) is native('Tilengine') { * }
method SetLastError(Pointer $error) { TLN_SetLastError($error) }

my sub TLN_GetLastError() returns Pointer is native('Tilengine') { * }
method GetLastError() { TLN_GetLastError() }

my sub TLN_GetErrorString(Pointer) returns Pointer is native('Tilengine') { * }
method GetErrorString(Pointer $error) { TLN_GetErrorString($error) }


# 
# \anchor group_windowing
# \name Windowing
# Built-in window and input management
my sub TLN_CreateWindow(Str, int32) returns bool is native('Tilengine') { * }
method CreateWindow(Str $overlay, int32 $flags) { TLN_CreateWindow($overlay, $flags) }

my sub TLN_CreateWindowThread(Pointer, Pointer) returns bool is native('Tilengine') { * }
method CreateWindowThread(Pointer $overlay, Pointer $flags) { TLN_CreateWindowThread($overlay, $flags) }

my sub TLN_SetWindowTitle(Pointer) is native('Tilengine') { * }
method SetWindowTitle(Pointer $title) { TLN_SetWindowTitle($title) }

my sub TLN_ProcessWindow() returns bool is native('Tilengine') { * }
method ProcessWindow() { TLN_ProcessWindow() }

my sub TLN_IsWindowActive() returns bool is native('Tilengine') { * }
method IsWindowActive() { TLN_IsWindowActive() }

my sub TLN_GetInput(int32) returns bool is native('Tilengine') { * }
method GetInput(int32 $id) { TLN_GetInput($id) }

my sub TLN_GetLastInput() returns int32 is native('Tilengine') { * }
method GetLastInput() { TLN_GetLastInput() }

my sub TLN_DrawFrame(int32) is native('Tilengine') { * }
method DrawFrame(int32 $time) { TLN_DrawFrame($time) }

my sub TLN_WaitRedraw() is native('Tilengine') { * }
method WaitRedraw() { TLN_WaitRedraw() }

my sub TLN_DeleteWindow() is native('Tilengine') { * }
method DeleteWindow() { TLN_DeleteWindow() }

my sub TLN_EnableBlur(bool) is native('Tilengine') { * }
method EnableBlur(bool $mode) { TLN_EnableBlur($mode) }

my sub TLN_Delay(DWORD) is native('Tilengine') { * }
method Delay(DWORD $msecs) { TLN_Delay($msecs) }

my sub TLN_GetTicks() returns DWORD is native('Tilengine') { * }
method GetTicks() { TLN_GetTicks() }

my sub TLN_BeginWindowFrame(int32) is native('Tilengine') { * }
method BeginWindowFrame(int32 $time) { TLN_BeginWindowFrame($time) }

my sub TLN_EndWindowFrame() is native('Tilengine') { * }
method EndWindowFrame() { TLN_EndWindowFrame() }



# 
# \anchor group_spriteset
# \name Spritesets
# Spriteset resources management for sprites
my sub TLN_CreateSpriteset(int32, Pointer, Pointer, int32, int32, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateSpriteset(int32 $entries, Pointer $rects, Pointer $data, int32 $width, int32 $height, int32 $pitch, Pointer $palette) { TLN_CreateSpriteset($entries, $rects, $data, $width, $height, $pitch, $palette) }

my sub TLN_LoadSpriteset(Str) returns Pointer is native('Tilengine') { * }
method LoadSpriteset(Str $name) { TLN_LoadSpriteset($name) }

my sub TLN_CloneSpriteset(Pointer) returns Pointer is native('Tilengine') { * }
method CloneSpriteset(Pointer $src) { TLN_CloneSpriteset($src) }

my sub TLN_GetSpriteInfo(Pointer, int32, Pointer) returns bool is native('Tilengine') { * }
method GetSpriteInfo(Pointer $spriteset, int32 $entry, Pointer $info) { TLN_GetSpriteInfo($spriteset, $entry, $info) }

my sub TLN_GetSpritesetPalette(Pointer) returns Pointer is native('Tilengine') { * }
method GetSpritesetPalette(Pointer $spriteset) { TLN_GetSpritesetPalette($spriteset) }

my sub TLN_DeleteSpriteset(Pointer) returns bool is native('Tilengine') { * }
method DeleteSpriteset(Pointer $Spriteset) { TLN_DeleteSpriteset($Spriteset) }


# 
# \anchor group_tileset
# \name Tilesets
# Tileset resources management for background layers
my sub TLN_CreateTileset(int32, int32, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateTileset(int32 $numtiles, int32 $width, int32 $height, Pointer $palette) { TLN_CreateTileset($numtiles, $width, $height, $palette) }

my sub TLN_LoadTileset(Str) returns Pointer is native('Tilengine') { * }
method LoadTileset(Str $filename) { TLN_LoadTileset($filename) }

my sub TLN_CloneTileset(Pointer) returns Pointer is native('Tilengine') { * }
method CloneTileset(Pointer $src) { TLN_CloneTileset($src) }

my sub TLN_SetTilesetPixels(Pointer, int32, Pointer, int32) returns bool is native('Tilengine') { * }
method SetTilesetPixels(Pointer $tileset, int32 $entry, Pointer $srcdata, int32 $srcpitch) { TLN_SetTilesetPixels($tileset, $entry, $srcdata, $srcpitch) }

my sub TLN_CopyTile(Pointer, int32, int32) returns bool is native('Tilengine') { * }
method CopyTile(Pointer $tileset, int32 $src, int32 $dst) { TLN_CopyTile($tileset, $src, $dst) }

my sub TLN_GetTileWidth(Pointer) returns int32 is native('Tilengine') { * }
method GetTileWidth(Pointer $tileset) { TLN_GetTileWidth($tileset) }

my sub TLN_GetTileHeight(Pointer) returns int32 is native('Tilengine') { * }
method GetTileHeight(Pointer $tileset) { TLN_GetTileHeight($tileset) }

my sub TLN_GetTilesetPalette(Pointer) returns Pointer is native('Tilengine') { * }
method GetTilesetPalette(Pointer $tileset) { TLN_GetTilesetPalette($tileset) }

my sub TLN_DeleteTileset(Pointer) returns bool is native('Tilengine') { * }
method DeleteTileset(Pointer $tileset) { TLN_DeleteTileset($tileset) }


# 
# \anchor group_tilemap
# \name Tilemaps 
# Tilemap resources management for background layers
my sub TLN_CreateTilemap(int32, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateTilemap(int32 $rows, int32 $cols, Pointer $tiles) { TLN_CreateTilemap($rows, $cols, $tiles) }

my sub TLN_LoadTilemap(Str, Str) returns Pointer is native('Tilengine') { * }
method LoadTilemap(Str $filename, Str $layername) { TLN_LoadTilemap($filename, $layername) }

my sub TLN_CloneTilemap(Pointer) returns Pointer is native('Tilengine') { * }
method CloneTilemap(Pointer $src) { TLN_CloneTilemap($src) }

my sub TLN_GetTilemapRows(Pointer) returns int32 is native('Tilengine') { * }
method GetTilemapRows(Pointer $tilemap) { TLN_GetTilemapRows($tilemap) }

my sub TLN_GetTilemapCols(Pointer) returns int32 is native('Tilengine') { * }
method GetTilemapCols(Pointer $tilemap) { TLN_GetTilemapCols($tilemap) }

my sub TLN_GetTilemapTile(Pointer, int32, int32, Tile) returns bool is native('Tilengine') { * }
method GetTilemapTile(Pointer $tilemap, int32 $row, int32 $col, Tile $tile) { TLN_GetTilemapTile($tilemap, $row, $col, $tile) }

my sub TLN_SetTilemapTile(Pointer, int32, int32, Tile) returns bool is native('Tilengine') { * }
method SetTilemapTile(Pointer $tilemap, int32 $row, int32 $col, Tile $tile) { TLN_SetTilemapTile($tilemap, $row, $col, $tile) }

my sub TLN_CopyTiles(Pointer, int32, int32, int32, int32, Pointer, int32, int32) returns bool is native('Tilengine') { * }
method CopyTiles(Pointer $src, int32 $srcrow, int32 $srccol, int32 $rows, int32 $cols, Pointer $dst, int32 $dstrow, int32 $dstcol) { TLN_CopyTiles($src, $srcrow, $srccol, $rows, $cols, $dst, $dstrow, $dstcol) }

my sub TLN_DeleteTilemap(Pointer) returns bool is native('Tilengine') { * }
method DeleteTilemap(Pointer $tilemap) { TLN_DeleteTilemap($tilemap) }


# 
# \anchor group_palette
# \name Palettes
# Color palette resources management for sprites and background layers
my sub TLN_CreatePalette(int32) returns Pointer is native('Tilengine') { * }
method CreatePalette(int32 $entries) { TLN_CreatePalette($entries) }

my sub TLN_LoadPalette(Pointer) returns Pointer is native('Tilengine') { * }
method LoadPalette(Pointer $filename) { TLN_LoadPalette($filename) }

my sub TLN_ClonePalette(Pointer) returns Pointer is native('Tilengine') { * }
method ClonePalette(Pointer $src) { TLN_ClonePalette($src) }

my sub TLN_SetPaletteColor(Pointer, int32, BYTE, BYTE, BYTE) returns bool is native('Tilengine') { * }
method SetPaletteColor(Pointer $palette, int32 $color, BYTE $r, BYTE $g, BYTE $b) { TLN_SetPaletteColor($palette, $color, $r, $g, $b) }

my sub TLN_MixPalettes(Pointer, Pointer, Pointer, BYTE) returns bool is native('Tilengine') { * }
method MixPalettes(Pointer $src1, Pointer $src2, Pointer $dst, BYTE $factor) { TLN_MixPalettes($src1, $src2, $dst, $factor) }

my sub TLN_GetPaletteData(Pointer, int32) returns Pointer is native('Tilengine') { * }
method GetPaletteData(Pointer $palette, int32 $index) { TLN_GetPaletteData($palette, $index) }

my sub TLN_DeletePalette(Pointer) returns bool is native('Tilengine') { * }
method DeletePalette(Pointer $palette) { TLN_DeletePalette($palette) }


# 
# \anchor group_bitmap
# \name Bitmaps 
# Bitmap management
my sub TLN_CreateBitmap(int32, int32, int32) returns Pointer is native('Tilengine') { * }
method CreateBitmap(int32 $width, int32 $height, int32 $bpp) { TLN_CreateBitmap($width, $height, $bpp) }

my sub TLN_LoadBitmap(Pointer) returns Pointer is native('Tilengine') { * }
method LoadBitmap(Pointer $filename) { TLN_LoadBitmap($filename) }

my sub TLN_CloneBitmap(Pointer) returns Pointer is native('Tilengine') { * }
method CloneBitmap(Pointer $src) { TLN_CloneBitmap($src) }

my sub TLN_GetBitmapPtr(Pointer, int32, int32) returns Pointer is native('Tilengine') { * }
method GetBitmapPtr(Pointer $bitmap, int32 $x, int32 $y) { TLN_GetBitmapPtr($bitmap, $x, $y) }

my sub TLN_GetBitmapWidth(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapWidth(Pointer $bitmap) { TLN_GetBitmapWidth($bitmap) }

my sub TLN_GetBitmapHeight(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapHeight(Pointer $bitmap) { TLN_GetBitmapHeight($bitmap) }

my sub TLN_GetBitmapDepth(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapDepth(Pointer $bitmap) { TLN_GetBitmapDepth($bitmap) }

my sub TLN_GetBitmapPitch(Pointer) returns int32 is native('Tilengine') { * }
method GetBitmapPitch(Pointer $bitmap) { TLN_GetBitmapPitch($bitmap) }

my sub TLN_GetBitmapPalette(Pointer) returns Pointer is native('Tilengine') { * }
method GetBitmapPalette(Pointer $bitmap) { TLN_GetBitmapPalette($bitmap) }

my sub TLN_SetBitmapPalette(Pointer, Pointer) returns bool is native('Tilengine') { * }
method SetBitmapPalette(Pointer $bitmap, Pointer $palette) { TLN_SetBitmapPalette($bitmap, $palette) }

my sub TLN_DeleteBitmap(Pointer) returns bool is native('Tilengine') { * }
method DeleteBitmap(Pointer $bitmap) { TLN_DeleteBitmap($bitmap) }


# 
# \anchor group_layer
# \name Layers
# Background layers management
my sub TLN_SetLayer(int32, Pointer, Pointer) returns bool is native('Tilengine') { * }
method SetLayer(int32 $nlayer, Pointer $tileset, Pointer $tilemap) { TLN_SetLayer($nlayer, $tileset, $tilemap) }

my sub TLN_SetLayerPalette(int32, Pointer) returns bool is native('Tilengine') { * }
method SetLayerPalette(int32 $nlayer, Pointer $palette) { TLN_SetLayerPalette($nlayer, $palette) }

my sub TLN_SetLayerPosition(int32, int32, int32) returns bool is native('Tilengine') { * }
method SetLayerPosition(int32 $nlayer, int32 $hstart, int32 $vstart) { TLN_SetLayerPosition($nlayer, $hstart, $vstart) }

my sub TLN_SetLayerScaling(int32, num32, num32) returns bool is native('Tilengine') { * }
method SetLayerScaling(int32 $nlayer, num32 $xfactor, num32 $yfactor) { TLN_SetLayerScaling($nlayer, $xfactor, $yfactor) }

my sub TLN_SetLayerAffineTransform(int32, Pointer) returns bool is native('Tilengine') { * }
method SetLayerAffineTransform(int32 $nlayer, Pointer $affine) { TLN_SetLayerAffineTransform($nlayer, $affine) }

my sub TLN_SetLayerTransform(int32, num32, num32, num32, num32, num32) returns bool is native('Tilengine') { * }
method SetLayerTransform(int32 $layer, num32 $angle, num32 $dx, num32 $dy, num32 $sx, num32 $sy) { TLN_SetLayerTransform($layer, $angle, $dx, $dy, $sx, $sy) }

my sub TLN_SetLayerBlendMode(int32, Pointer, BYTE) returns bool is native('Tilengine') { * }
method SetLayerBlendMode(int32 $nlayer, Pointer $mode, BYTE $factor) { TLN_SetLayerBlendMode($nlayer, $mode, $factor) }

my sub TLN_SetLayerColumnOffset(int32, Pointer) returns bool is native('Tilengine') { * }
method SetLayerColumnOffset(int32 $nlayer, Pointer $offset) { TLN_SetLayerColumnOffset($nlayer, $offset) }

my sub TLN_ResetLayerMode(int32) returns bool is native('Tilengine') { * }
method ResetLayerMode(int32 $nlayer) { TLN_ResetLayerMode($nlayer) }

my sub TLN_DisableLayer(int32) returns bool is native('Tilengine') { * }
method DisableLayer(int32 $nlayer) { TLN_DisableLayer($nlayer) }

my sub TLN_GetLayerPalette(int32) returns Pointer is native('Tilengine') { * }
method GetLayerPalette(int32 $nlayer) { TLN_GetLayerPalette($nlayer) }

my sub TLN_GetLayerTile(int32, int32, int32, Pointer) returns bool is native('Tilengine') { * }
method GetLayerTile(int32 $nlayer, int32 $x, int32 $y, Pointer $info) { TLN_GetLayerTile($nlayer, $x, $y, $info) }


# 
# \anchor group_sprite
# \name Sprites 
# Sprites management
my sub TLN_ConfigSprite(int32, Pointer, int32) returns bool is native('Tilengine') { * }
method ConfigSprite(int32 $nsprite, Pointer $spriteset, int32 $flags) { TLN_ConfigSprite($nsprite, $spriteset, $flags) }

my sub TLN_SetSpriteSet(int32, Pointer) returns bool is native('Tilengine') { * }
method SetSpriteSet(int32 $nsprite, Pointer $spriteset) { TLN_SetSpriteSet($nsprite, $spriteset) }

my sub TLN_SetSpriteFlags(int32, Pointer) returns bool is native('Tilengine') { * }
method SetSpriteFlags(int32 $nsprite, Pointer $flags) { TLN_SetSpriteFlags($nsprite, $flags) }

my sub TLN_SetSpritePosition(int32, int32, int32) returns bool is native('Tilengine') { * }
method SetSpritePosition(int32 $nsprite, int32 $x, int32 $y) { TLN_SetSpritePosition($nsprite, $x, $y) }

my sub TLN_SetSpritePicture(int32, int32) returns bool is native('Tilengine') { * }
method SetSpritePicture(int32 $nsprite, int32 $entry) { TLN_SetSpritePicture($nsprite, $entry) }

my sub TLN_SetSpritePalette(int32, Pointer) returns bool is native('Tilengine') { * }
method SetSpritePalette(int32 $nsprite, Pointer $palette) { TLN_SetSpritePalette($nsprite, $palette) }

my sub TLN_SetSpriteBlendMode(int32, Pointer, BYTE) returns bool is native('Tilengine') { * }
method SetSpriteBlendMode(int32 $nsprite, Pointer $mode, BYTE $factor) { TLN_SetSpriteBlendMode($nsprite, $mode, $factor) }

my sub TLN_SetSpriteScaling(int32, num32, num32) returns bool is native('Tilengine') { * }
method SetSpriteScaling(int32 $nsprite, num32 $sx, num32 $sy) { TLN_SetSpriteScaling($nsprite, $sx, $sy) }

my sub TLN_ResetSpriteScaling(int32) returns bool is native('Tilengine') { * }
method ResetSpriteScaling(int32 $nsprite) { TLN_ResetSpriteScaling($nsprite) }

my sub TLN_GetSpritePicture(int32) returns int32 is native('Tilengine') { * }
method GetSpritePicture(int32 $nsprite) { TLN_GetSpritePicture($nsprite) }

my sub TLN_GetAvailableSprite() returns int32 is native('Tilengine') { * }
method GetAvailableSprite() { TLN_GetAvailableSprite() }

my sub TLN_EnableSpriteCollision(int32, bool) returns bool is native('Tilengine') { * }
method EnableSpriteCollision(int32 $nsprite, bool $enable) { TLN_EnableSpriteCollision($nsprite, $enable) }

my sub TLN_GetSpriteCollision(int32) returns bool is native('Tilengine') { * }
method GetSpriteCollision(int32 $nsprite) { TLN_GetSpriteCollision($nsprite) }

my sub TLN_DisableSprite(int32) returns bool is native('Tilengine') { * }
method DisableSprite(int32 $nsprite) { TLN_DisableSprite($nsprite) }

my sub TLN_GetSpritePalette(int32) returns Pointer is native('Tilengine') { * }
method GetSpritePalette(int32 $nsprite) { TLN_GetSpritePalette($nsprite) }


# 
# \anchor group_sequence
# \name Sequences
# Sequence resources management for layer, sprite and palette animations
my sub TLN_CreateSequence(Pointer, int32, int32, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateSequence(Pointer $name, int32 $delay, int32 $first, int32 $num_frames, Pointer $data) { TLN_CreateSequence($name, $delay, $first, $num_frames, $data) }

my sub TLN_CreateCycle(Pointer, int32, Pointer) returns Pointer is native('Tilengine') { * }
method CreateCycle(Pointer $name, int32 $num_strips, Pointer $strips) { TLN_CreateCycle($name, $num_strips, $strips) }

my sub TLN_CloneSequence(Pointer) returns Pointer is native('Tilengine') { * }
method CloneSequence(Pointer $src) { TLN_CloneSequence($src) }

my sub TLN_DeleteSequence(Pointer) returns bool is native('Tilengine') { * }
method DeleteSequence(Pointer $sequence) { TLN_DeleteSequence($sequence) }


# 
# \anchor group_sequencepack
# \name Sequence packs
# Sequence pack manager for grouping and finding sequences
my sub TLN_CreateSequencePack() returns Pointer is native('Tilengine') { * }
method CreateSequencePack() { TLN_CreateSequencePack() }

my sub TLN_LoadSequencePack(Str) returns Pointer is native('Tilengine') { * }
method LoadSequencePack(Str $filename) { TLN_LoadSequencePack($filename) }

my sub TLN_FindSequence(Pointer, Str) returns Pointer is native('Tilengine') { * }
method FindSequence(Pointer $sp, Str $name) { TLN_FindSequence($sp, $name) }

my sub TLN_AddSequenceToPack(Pointer, Pointer) returns bool is native('Tilengine') { * }
method AddSequenceToPack(Pointer $sp, Pointer $sequence) { TLN_AddSequenceToPack($sp, $sequence) }

my sub TLN_DeleteSequencePack(Pointer) returns bool is native('Tilengine') { * }
method DeleteSequencePack(Pointer $sp) { TLN_DeleteSequencePack($sp) }


# 
# \anchor group_animation
# \name Animations 
# Animation engine manager
my sub TLN_SetPaletteAnimation(int32, Pointer, Pointer, bool) returns bool is native('Tilengine') { * }
method SetPaletteAnimation(int32 $index, Pointer $palette, TLN_Sequence $sequence, bool $blend) { TLN_SetPaletteAnimation($index, $palette, $sequence, $blend) }

my sub TLN_SetPaletteAnimationSource(int32, Pointer) returns bool is native('Tilengine') { * }
method SetPaletteAnimationSource(int32 $index, Pointer $palette) { TLN_SetPaletteAnimationSource($index, $palette) }

my sub TLN_SetTilesetAnimation(int32, int32, Pointer) returns bool is native('Tilengine') { * }
method SetTilesetAnimation(int32 $index, int32 $nlayer, Pointer $sequence) { TLN_SetTilesetAnimation($index, $nlayer, $sequence) }

my sub TLN_SetTilemapAnimation(int32, int32, Pointer) returns bool is native('Tilengine') { * }
method SetTilemapAnimation(int32 $index, int32 $nlayer, Pointer $sequence) { TLN_SetTilemapAnimation($index, $nlayer, $sequence) }

my sub TLN_SetSpriteAnimation(int32, int32, Pointer, int32) returns bool is native('Tilengine') { * }
method SetSpriteAnimation(int32 $index, int32 $nsprite, Pointer $sequence, int32 $loop) { TLN_SetSpriteAnimation($index, $nsprite, $sequence, $loop) }

my sub TLN_GetAnimationState(int32) returns bool is native('Tilengine') { * }
method GetAnimationState(int32 $index) { TLN_GetAnimationState($index) }

my sub TLN_SetAnimationDelay(int32, int32) returns bool is native('Tilengine') { * }
method SetAnimationDelay(int32 $index, int32 $delay) { TLN_SetAnimationDelay($index, $delay) }

my sub TLN_GetAvailableAnimation() returns int32 is native('Tilengine') { * }
method GetAvailableAnimation() { TLN_GetAvailableAnimation() }

my sub TLN_DisableAnimation(int32) returns bool is native('Tilengine') { * }
method DisableAnimation(int32 $index) { TLN_DisableAnimation($index) }



