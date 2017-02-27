use v6;
unit module Tilengine:ver<117.2.19>:auth<Joaquin Ferrero (jferrero@gmail.com)>;

use NativeCall;

class Tilengine is export {

    my sub TLN_Init(int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * }
    method Init (int32 $hres, int32 $vres, int32 $numlayers, int32 $numsprites, int32 $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) };

    my sub TLN_InitBPP(int32, int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * }
    method InitBPP (int32 $hres, int32 $vres, int32 $bpp, int32 $numlayers, int32 $numsprites, int32 $numanimations) { TLN_InitBPP($hres, $vres, $bpp, $numlayers, $numsprites, $numanimations) };

    my sub TLN_Deinit(void) is native('Tilengine') { * }
    method Deinit (void) { TLN_Deinit() };

    my sub TLN_GetWidth(void) returns int32 is native('Tilengine') { * }
    method GetWidth (void) { TLN_GetWidth() };

    my sub TLN_GetHeight(void) returns int32 is native('Tilengine') { * }
    method GetHeight (void) { TLN_GetHeight() };

    my sub TLN_GetBPP(void) returns int32 is native('Tilengine') { * }
    method GetBPP (void) { TLN_GetBPP() };

    my sub TLN_GetNumObjects(void) returns DWORD is native('Tilengine') { * }
    method GetNumObjects (void) { TLN_GetNumObjects() };

    my sub TLN_GetUsedMemory(void) returns DWORD is native('Tilengine') { * }
    method GetUsedMemory (void) { TLN_GetUsedMemory() };

    my sub TLN_GetVersion(void) returns DWORD is native('Tilengine') { * }
    method GetVersion (void) { TLN_GetVersion() };

    my sub TLN_GetNumLayers(void) returns int32 is native('Tilengine') { * }
    method GetNumLayers (void) { TLN_GetNumLayers() };

    my sub TLN_GetNumSprites(void) returns int32 is native('Tilengine') { * }
    method GetNumSprites (void) { TLN_GetNumSprites() };

    my sub TLN_SetBGColor(uint8, uint8, uint8) is native('Tilengine') { * }
    method SetBGColor (uint8 $r, uint8 $g, uint8 $b) { TLN_SetBGColor($r, $g, $b) };

    my sub TLN_SetBGBitmap(TLN_Bitmap) returns bool is native('Tilengine') { * }
    method SetBGBitmap (TLN_Bitmap $bitmap) { TLN_SetBGBitmap($bitmap) };

    my sub TLN_SetBGPalette(TLN_Palette) returns bool is native('Tilengine') { * }
    method SetBGPalette (TLN_Palette $palette) { TLN_SetBGPalette($palette) };

    my sub TLN_SetRasterCallback(void (*callback)(int32)) is native('Tilengine') { * }
    method SetRasterCallback (void (*callback)(int32)) { TLN_SetRasterCallback() };

    my sub TLN_SetRenderTarget(uint8*, int32) is native('Tilengine') { * }
    method SetRenderTarget (uint8* $data, int32 $pitch) { TLN_SetRenderTarget($data, $pitch) };

    my sub TLN_UpdateFrame(int32) is native('Tilengine') { * }
    method UpdateFrame (int32 $time) { TLN_UpdateFrame($time) };

    my sub TLN_BeginFrame(int32) is native('Tilengine') { * }
    method BeginFrame (int32 $time) { TLN_BeginFrame($time) };

    my sub TLN_DrawNextScanline(void) returns bool is native('Tilengine') { * }
    method DrawNextScanline (void) { TLN_DrawNextScanline() };

    my sub TLN_SetLoadPath(Pointer) is native('Tilengine') { * }
    method SetLoadPath (Pointer $path) { TLN_SetLoadPath($path) };

    my sub TLN_SetLastError(TLN_Error) is native('Tilengine') { * }
    method SetLastError (TLN_Error $error) { TLN_SetLastError($error) };

    my sub TLN_GetLastError(void) returns TLN_Error is native('Tilengine') { * }
    method GetLastError (void) { TLN_GetLastError() };

    my sub TLN_GetErrorString(TLN_Error) returns Pointer is native('Tilengine') { * }
    method GetErrorString (TLN_Error $error) { TLN_GetErrorString($error) };

    my sub TLN_CreateWindow(Pointer, TLN_WindowFlags) returns bool is native('Tilengine') { * }
    method CreateWindow (Pointer $overlay, TLN_WindowFlags $flags) { TLN_CreateWindow($overlay, $flags) };

    my sub TLN_CreateWindowThread(Pointer, TLN_WindowFlags) returns bool is native('Tilengine') { * }
    method CreateWindowThread (Pointer $overlay, TLN_WindowFlags $flags) { TLN_CreateWindowThread($overlay, $flags) };

    my sub TLN_SetWindowTitle(Pointer) is native('Tilengine') { * }
    method SetWindowTitle (Pointer $title) { TLN_SetWindowTitle($title) };

    my sub TLN_ProcessWindow(void) returns bool is native('Tilengine') { * }
    method ProcessWindow (void) { TLN_ProcessWindow() };

    my sub TLN_IsWindowActive(void) returns bool is native('Tilengine') { * }
    method IsWindowActive (void) { TLN_IsWindowActive() };

    my sub TLN_GetInput(TLN_Input) returns bool is native('Tilengine') { * }
    method GetInput (TLN_Input $id) { TLN_GetInput($id) };

    my sub TLN_DrawFrame(int32) is native('Tilengine') { * }
    method DrawFrame (int32 $time) { TLN_DrawFrame($time) };

    my sub TLN_WaitRedraw(void) is native('Tilengine') { * }
    method WaitRedraw (void) { TLN_WaitRedraw() };

    my sub TLN_DeleteWindow(void) is native('Tilengine') { * }
    method DeleteWindow (void) { TLN_DeleteWindow() };

    my sub TLN_EnableBlur(bool) is native('Tilengine') { * }
    method EnableBlur (bool $mode) { TLN_EnableBlur($mode) };

    my sub TLN_Delay(DWORD) is native('Tilengine') { * }
    method Delay (DWORD $msecs) { TLN_Delay($msecs) };

    my sub TLN_GetTicks(void) returns DWORD is native('Tilengine') { * }
    method GetTicks (void) { TLN_GetTicks() };

    my sub TLN_BeginWindowFrame(int32) is native('Tilengine') { * }
    method BeginWindowFrame (int32 $time) { TLN_BeginWindowFrame($time) };

    my sub TLN_EndWindowFrame(void) is native('Tilengine') { * }
    method EndWindowFrame (void) { TLN_EndWindowFrame() };

    my sub TLN_CreateSpriteset(int32, TLN_Rect*, uint8*, int32, int32, int32, TLN_Palette) returns TLN_Spriteset is native('Tilengine') { * }
    method CreateSpriteset (int32 $entries, TLN_Rect* $rects, uint8* $data, int32 $width, int32 $height, int32 $pitch, TLN_Palette $palette) { TLN_CreateSpriteset($entries, $rects, $data, $width, $height, $pitch, $palette) };

    my sub TLN_LoadSpriteset(Pointer) returns TLN_Spriteset is native('Tilengine') { * }
    method LoadSpriteset (Pointer $name) { TLN_LoadSpriteset($name) };

    my sub TLN_CloneSpriteset(TLN_Spriteset) returns TLN_Spriteset is native('Tilengine') { * }
    method CloneSpriteset (TLN_Spriteset $src) { TLN_CloneSpriteset($src) };

    my sub TLN_GetSpriteInfo(TLN_Spriteset, int32, TLN_SpriteInfo*) returns bool is native('Tilengine') { * }
    method GetSpriteInfo (TLN_Spriteset $spriteset, int32 $entry, TLN_SpriteInfo* $info) { TLN_GetSpriteInfo($spriteset, $entry, $info) };

    my sub TLN_GetSpritesetPalette(TLN_Spriteset) returns TLN_Palette is native('Tilengine') { * }
    method GetSpritesetPalette (TLN_Spriteset $spriteset) { TLN_GetSpritesetPalette($spriteset) };

    my sub TLN_DeleteSpriteset(TLN_Spriteset) returns bool is native('Tilengine') { * }
    method DeleteSpriteset (TLN_Spriteset $Spriteset) { TLN_DeleteSpriteset($Spriteset) };

    my sub TLN_CreateTileset(int32, int32, int32, TLN_Palette) returns TLN_Tileset is native('Tilengine') { * }
    method CreateTileset (int32 $numtiles, int32 $width, int32 $height, TLN_Palette $palette) { TLN_CreateTileset($numtiles, $width, $height, $palette) };

    my sub TLN_LoadTileset(Pointer) returns TLN_Tileset is native('Tilengine') { * }
    method LoadTileset (Pointer $filename) { TLN_LoadTileset($filename) };

    my sub TLN_CloneTileset(TLN_Tileset) returns TLN_Tileset is native('Tilengine') { * }
    method CloneTileset (TLN_Tileset $src) { TLN_CloneTileset($src) };

    my sub TLN_SetTilesetPixels(TLN_Tileset, int32, uint8*, int32) returns bool is native('Tilengine') { * }
    method SetTilesetPixels (TLN_Tileset $tileset, int32 $entry, uint8* $srcdata, int32 $srcpitch) { TLN_SetTilesetPixels($tileset, $entry, $srcdata, $srcpitch) };

    my sub TLN_CopyTile(TLN_Tileset, int32, int32) returns bool is native('Tilengine') { * }
    method CopyTile (TLN_Tileset $tileset, int32 $src, int32 $dst) { TLN_CopyTile($tileset, $src, $dst) };

    my sub TLN_GetTileWidth(TLN_Tileset) returns int32 is native('Tilengine') { * }
    method GetTileWidth (TLN_Tileset $tileset) { TLN_GetTileWidth($tileset) };

    my sub TLN_GetTileHeight(TLN_Tileset) returns int32 is native('Tilengine') { * }
    method GetTileHeight (TLN_Tileset $tileset) { TLN_GetTileHeight($tileset) };

    my sub TLN_GetTilesetPalette(TLN_Tileset) returns TLN_Palette is native('Tilengine') { * }
    method GetTilesetPalette (TLN_Tileset $tileset) { TLN_GetTilesetPalette($tileset) };

    my sub TLN_DeleteTileset(TLN_Tileset) returns bool is native('Tilengine') { * }
    method DeleteTileset (TLN_Tileset $tileset) { TLN_DeleteTileset($tileset) };

    my sub TLN_CreateTilemap(int32, int32, TLN_Tile) returns TLN_Tilemap is native('Tilengine') { * }
    method CreateTilemap (int32 $rows, int32 $cols, TLN_Tile $tiles) { TLN_CreateTilemap($rows, $cols, $tiles) };

    my sub TLN_LoadTilemap(Pointer, Pointer) returns TLN_Tilemap is native('Tilengine') { * }
    method LoadTilemap (Pointer $filename, Pointer $layername) { TLN_LoadTilemap($filename, $layername) };

    my sub TLN_CloneTilemap(TLN_Tilemap) returns TLN_Tilemap is native('Tilengine') { * }
    method CloneTilemap (TLN_Tilemap $src) { TLN_CloneTilemap($src) };

    my sub TLN_GetTilemapRows(TLN_Tilemap) returns int32 is native('Tilengine') { * }
    method GetTilemapRows (TLN_Tilemap $tilemap) { TLN_GetTilemapRows($tilemap) };

    my sub TLN_GetTilemapCols(TLN_Tilemap) returns int32 is native('Tilengine') { * }
    method GetTilemapCols (TLN_Tilemap $tilemap) { TLN_GetTilemapCols($tilemap) };

    my sub TLN_GetTilemapTile(TLN_Tilemap, int32, int32, TLN_Tile) returns bool is native('Tilengine') { * }
    method GetTilemapTile (TLN_Tilemap $tilemap, int32 $row, int32 $col, TLN_Tile $tile) { TLN_GetTilemapTile($tilemap, $row, $col, $tile) };

    my sub TLN_SetTilemapTile(TLN_Tilemap, int32, int32, TLN_Tile) returns bool is native('Tilengine') { * }
    method SetTilemapTile (TLN_Tilemap $tilemap, int32 $row, int32 $col, TLN_Tile $tile) { TLN_SetTilemapTile($tilemap, $row, $col, $tile) };

    my sub TLN_CopyTiles(TLN_Tilemap, int32, int32, int32, int32, TLN_Tilemap, int32, int32) returns bool is native('Tilengine') { * }
    method CopyTiles (TLN_Tilemap $src, int32 $srcrow, int32 $srccol, int32 $rows, int32 $cols, TLN_Tilemap $dst, int32 $dstrow, int32 $dstcol) { TLN_CopyTiles($src, $srcrow, $srccol, $rows, $cols, $dst, $dstrow, $dstcol) };

    my sub TLN_DeleteTilemap(TLN_Tilemap) returns bool is native('Tilengine') { * }
    method DeleteTilemap (TLN_Tilemap $tilemap) { TLN_DeleteTilemap($tilemap) };

    my sub TLN_CreatePalette(int32) returns TLN_Palette is native('Tilengine') { * }
    method CreatePalette (int32 $entries) { TLN_CreatePalette($entries) };

    my sub TLN_LoadPalette(Pointer) returns TLN_Palette is native('Tilengine') { * }
    method LoadPalette (Pointer $filename) { TLN_LoadPalette($filename) };

    my sub TLN_ClonePalette(TLN_Palette) returns TLN_Palette is native('Tilengine') { * }
    method ClonePalette (TLN_Palette $src) { TLN_ClonePalette($src) };

    my sub TLN_SetPaletteColor(TLN_Palette, int32, uint8, uint8, uint8) returns bool is native('Tilengine') { * }
    method SetPaletteColor (TLN_Palette $palette, int32 $color, uint8 $r, uint8 $g, uint8 $b) { TLN_SetPaletteColor($palette, $color, $r, $g, $b) };

    my sub TLN_MixPalettes(TLN_Palette, TLN_Palette, TLN_Palette, uint8) returns bool is native('Tilengine') { * }
    method MixPalettes (TLN_Palette $src1, TLN_Palette $src2, TLN_Palette $dst, uint8 $factor) { TLN_MixPalettes($src1, $src2, $dst, $factor) };

    my sub TLN_DeletePalette(TLN_Palette) returns bool is native('Tilengine') { * }
    method DeletePalette (TLN_Palette $palette) { TLN_DeletePalette($palette) };

    my sub TLN_CreateBitmap(int32, int32, int32) returns TLN_Bitmap is native('Tilengine') { * }
    method CreateBitmap (int32 $width, int32 $height, int32 $bpp) { TLN_CreateBitmap($width, $height, $bpp) };

    my sub TLN_LoadBitmap(Pointer) returns TLN_Bitmap is native('Tilengine') { * }
    method LoadBitmap (Pointer $filename) { TLN_LoadBitmap($filename) };

    my sub TLN_CloneBitmap(TLN_Bitmap) returns TLN_Bitmap is native('Tilengine') { * }
    method CloneBitmap (TLN_Bitmap $src) { TLN_CloneBitmap($src) };

    my sub TLN_GetBitmapWidth(TLN_Bitmap) returns int32 is native('Tilengine') { * }
    method GetBitmapWidth (TLN_Bitmap $bitmap) { TLN_GetBitmapWidth($bitmap) };

    my sub TLN_GetBitmapHeight(TLN_Bitmap) returns int32 is native('Tilengine') { * }
    method GetBitmapHeight (TLN_Bitmap $bitmap) { TLN_GetBitmapHeight($bitmap) };

    my sub TLN_GetBitmapDepth(TLN_Bitmap) returns int32 is native('Tilengine') { * }
    method GetBitmapDepth (TLN_Bitmap $bitmap) { TLN_GetBitmapDepth($bitmap) };

    my sub TLN_GetBitmapPitch(TLN_Bitmap) returns int32 is native('Tilengine') { * }
    method GetBitmapPitch (TLN_Bitmap $bitmap) { TLN_GetBitmapPitch($bitmap) };

    my sub TLN_GetBitmapPalette(TLN_Bitmap) returns TLN_Palette is native('Tilengine') { * }
    method GetBitmapPalette (TLN_Bitmap $bitmap) { TLN_GetBitmapPalette($bitmap) };

    my sub TLN_SetBitmapPalette(TLN_Bitmap, TLN_Palette) returns bool is native('Tilengine') { * }
    method SetBitmapPalette (TLN_Bitmap $bitmap, TLN_Palette $palette) { TLN_SetBitmapPalette($bitmap, $palette) };

    my sub TLN_DeleteBitmap(TLN_Bitmap) returns bool is native('Tilengine') { * }
    method DeleteBitmap (TLN_Bitmap $bitmap) { TLN_DeleteBitmap($bitmap) };

    my sub TLN_SetLayer(int32, TLN_Tileset, TLN_Tilemap) returns bool is native('Tilengine') { * }
    method SetLayer (int32 $nlayer, TLN_Tileset $tileset, TLN_Tilemap $tilemap) { TLN_SetLayer($nlayer, $tileset, $tilemap) };

    my sub TLN_SetLayerPalette(int32, TLN_Palette) returns bool is native('Tilengine') { * }
    method SetLayerPalette (int32 $nlayer, TLN_Palette $palette) { TLN_SetLayerPalette($nlayer, $palette) };

    my sub TLN_SetLayerPosition(int32, int32, int32) returns bool is native('Tilengine') { * }
    method SetLayerPosition (int32 $nlayer, int32 $hstart, int32 $vstart) { TLN_SetLayerPosition($nlayer, $hstart, $vstart) };

    my sub TLN_SetLayerScaling(int32, float, float) returns bool is native('Tilengine') { * }
    method SetLayerScaling (int32 $nlayer, float $xfactor, float $yfactor) { TLN_SetLayerScaling($nlayer, $xfactor, $yfactor) };

    my sub TLN_SetLayerAffineTransform(int32, TLN_Affine *affine) returns bool is native('Tilengine') { * }
    method SetLayerAffineTransform (int32 $nlayer, TLN_Affine *affine) { TLN_SetLayerAffineTransform($nlayer) };

    my sub TLN_SetLayerTransform(int32, float, float, float, float, float) returns bool is native('Tilengine') { * }
    method SetLayerTransform (int32 $layer, float $angle, float $dx, float $dy, float $sx, float $sy) { TLN_SetLayerTransform($layer, $angle, $dx, $dy, $sx, $sy) };

    my sub TLN_SetLayerBlendMode(int32, TLN_Blend, uint8) returns bool is native('Tilengine') { * }
    method SetLayerBlendMode (int32 $nlayer, TLN_Blend $mode, uint8 $factor) { TLN_SetLayerBlendMode($nlayer, $mode, $factor) };

    my sub TLN_SetLayerColumnOffset(int32, int32*) returns bool is native('Tilengine') { * }
    method SetLayerColumnOffset (int32 $nlayer, int32* $offset) { TLN_SetLayerColumnOffset($nlayer, $offset) };

    my sub TLN_ResetLayerMode(int32) returns bool is native('Tilengine') { * }
    method ResetLayerMode (int32 $nlayer) { TLN_ResetLayerMode($nlayer) };

    my sub TLN_DisableLayer(int32) returns bool is native('Tilengine') { * }
    method DisableLayer (int32 $nlayer) { TLN_DisableLayer($nlayer) };

    my sub TLN_GetLayerPalette(int32) returns TLN_Palette is native('Tilengine') { * }
    method GetLayerPalette (int32 $nlayer) { TLN_GetLayerPalette($nlayer) };

    my sub TLN_GetLayerTile(int32, int32, int32, TLN_TileInfo*) returns bool is native('Tilengine') { * }
    method GetLayerTile (int32 $nlayer, int32 $x, int32 $y, TLN_TileInfo* $info) { TLN_GetLayerTile($nlayer, $x, $y, $info) };

    my sub TLN_ConfigSprite(int32, TLN_Spriteset, TLN_TileFlags) returns bool is native('Tilengine') { * }
    method ConfigSprite (int32 $nsprite, TLN_Spriteset $spriteset, TLN_TileFlags $flags) { TLN_ConfigSprite($nsprite, $spriteset, $flags) };

    my sub TLN_SetSpriteSet(int32, TLN_Spriteset) returns bool is native('Tilengine') { * }
    method SetSpriteSet (int32 $nsprite, TLN_Spriteset $spriteset) { TLN_SetSpriteSet($nsprite, $spriteset) };

    my sub TLN_SetSpriteFlags(int32, TLN_TileFlags) returns bool is native('Tilengine') { * }
    method SetSpriteFlags (int32 $nsprite, TLN_TileFlags $flags) { TLN_SetSpriteFlags($nsprite, $flags) };

    my sub TLN_SetSpritePosition(int32, int32, int32) returns bool is native('Tilengine') { * }
    method SetSpritePosition (int32 $nsprite, int32 $x, int32 $y) { TLN_SetSpritePosition($nsprite, $x, $y) };

    my sub TLN_SetSpritePicture(int32, int32) returns bool is native('Tilengine') { * }
    method SetSpritePicture (int32 $nsprite, int32 $entry) { TLN_SetSpritePicture($nsprite, $entry) };

    my sub TLN_SetSpritePalette(int32, TLN_Palette) returns bool is native('Tilengine') { * }
    method SetSpritePalette (int32 $nsprite, TLN_Palette $palette) { TLN_SetSpritePalette($nsprite, $palette) };

    my sub TLN_SetSpriteBlendMode(int32, TLN_Blend, uint8) returns bool is native('Tilengine') { * }
    method SetSpriteBlendMode (int32 $nsprite, TLN_Blend $mode, uint8 $factor) { TLN_SetSpriteBlendMode($nsprite, $mode, $factor) };

    my sub TLN_SetSpriteScaling(int32, float, float) returns bool is native('Tilengine') { * }
    method SetSpriteScaling (int32 $nsprite, float $sx, float $sy) { TLN_SetSpriteScaling($nsprite, $sx, $sy) };

    my sub TLN_ResetSpriteScaling(int32) returns bool is native('Tilengine') { * }
    method ResetSpriteScaling (int32 $nsprite) { TLN_ResetSpriteScaling($nsprite) };

    my sub TLN_EnableSpriteCollision(int32, bool) returns bool is native('Tilengine') { * }
    method EnableSpriteCollision (int32 $nsprite, bool $enable) { TLN_EnableSpriteCollision($nsprite, $enable) };

    my sub TLN_GetSpriteCollision(int32) returns bool is native('Tilengine') { * }
    method GetSpriteCollision (int32 $nsprite) { TLN_GetSpriteCollision($nsprite) };

    my sub TLN_DisableSprite(int32) returns bool is native('Tilengine') { * }
    method DisableSprite (int32 $nsprite) { TLN_DisableSprite($nsprite) };

    my sub TLN_GetSpritePalette(int32) returns TLN_Palette is native('Tilengine') { * }
    method GetSpritePalette (int32 $nsprite) { TLN_GetSpritePalette($nsprite) };

    my sub TLN_CreateSequence(Pointer, int32, int32, int32, int32*) returns TLN_Sequence is native('Tilengine') { * }
    method CreateSequence (Pointer $name, int32 $delay, int32 $first, int32 $num_frames, int32* $data) { TLN_CreateSequence($name, $delay, $first, $num_frames, $data) };

    my sub TLN_CreateCycle(Pointer, int32, TLN_ColorStrip*) returns TLN_Cycle is native('Tilengine') { * }
    method CreateCycle (Pointer $name, int32 $num_strips, TLN_ColorStrip* $strips) { TLN_CreateCycle($name, $num_strips, $strips) };

    my sub TLN_CloneSequence(TLN_Sequence) returns TLN_Sequence is native('Tilengine') { * }
    method CloneSequence (TLN_Sequence $src) { TLN_CloneSequence($src) };

    my sub TLN_DeleteSequence(TLN_Sequence) returns bool is native('Tilengine') { * }
    method DeleteSequence (TLN_Sequence $sequence) { TLN_DeleteSequence($sequence) };

    my sub TLN_CreateSequencePack(void) returns TLN_SequencePack is native('Tilengine') { * }
    method CreateSequencePack (void) { TLN_CreateSequencePack() };

    my sub TLN_LoadSequencePack(Pointer) returns TLN_SequencePack is native('Tilengine') { * }
    method LoadSequencePack (Pointer $filename) { TLN_LoadSequencePack($filename) };

    my sub TLN_FindSequence(TLN_SequencePack, Pointer) returns TLN_Sequence is native('Tilengine') { * }
    method FindSequence (TLN_SequencePack $sp, Pointer $name) { TLN_FindSequence($sp, $name) };

    my sub TLN_AddSequenceToPack(TLN_SequencePack, TLN_Sequence) returns bool is native('Tilengine') { * }
    method AddSequenceToPack (TLN_SequencePack $sp, TLN_Sequence $sequence) { TLN_AddSequenceToPack($sp, $sequence) };

    my sub TLN_DeleteSequencePack(TLN_SequencePack) returns bool is native('Tilengine') { * }
    method DeleteSequencePack (TLN_SequencePack $sp) { TLN_DeleteSequencePack($sp) };

    my sub TLN_SetPaletteAnimation(int32, TLN_Palette, TLN_Sequence, bool) returns bool is native('Tilengine') { * }
    method SetPaletteAnimation (int32 $index, TLN_Palette $palette, TLN_Sequence $sequence, bool $blend) { TLN_SetPaletteAnimation($index, $palette, $sequence, $blend) };

    my sub TLN_SetPaletteAnimationSource(int32, TLN_Palette) returns bool is native('Tilengine') { * }
    method SetPaletteAnimationSource (int32 $index, TLN_Palette) { TLN_SetPaletteAnimationSource($index) };

    my sub TLN_SetTilesetAnimation(int32, int32, TLN_Sequence) returns bool is native('Tilengine') { * }
    method SetTilesetAnimation (int32 $index, int32 $nlayer, TLN_Sequence) { TLN_SetTilesetAnimation($index, $nlayer) };

    my sub TLN_SetTilemapAnimation(int32, int32, TLN_Sequence) returns bool is native('Tilengine') { * }
    method SetTilemapAnimation (int32 $index, int32 $nlayer, TLN_Sequence) { TLN_SetTilemapAnimation($index, $nlayer) };

    my sub TLN_SetSpriteAnimation(int32, int32, TLN_Sequence, int32) returns bool is native('Tilengine') { * }
    method SetSpriteAnimation (int32 $index, int32 $nsprite, TLN_Sequence $sequence, int32 $loop) { TLN_SetSpriteAnimation($index, $nsprite, $sequence, $loop) };

    my sub TLN_GetAnimationState(int32) returns bool is native('Tilengine') { * }
    method GetAnimationState (int32 $index) { TLN_GetAnimationState($index) };

    my sub TLN_SetAnimationDelay(int32, int32) returns bool is native('Tilengine') { * }
    method SetAnimationDelay (int32 $index, int32 $delay) { TLN_SetAnimationDelay($index, $delay) };

    my sub TLN_DisableAnimation(int32) returns bool is native('Tilengine') { * }
    method DisableAnimation (int32 $index) { TLN_DisableAnimation($index) };

}
