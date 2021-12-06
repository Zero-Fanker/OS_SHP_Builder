unit SHP_Image;

interface

uses
   Windows, SHP_File, Palette, ExtCtrls, Classes, Graphics, SHP_Shadows, SysUtils, Math;

type
   TColourMatch = record
      Original: TColor;
      Match:    byte;
   end;

   TShadowMatch = array [0..255] of TColourMatch;

 // Drawing Procedures/Functions
 // Misc
function ColourToTRGB32(const Colour: Tcolor): TRGB32;
function OpositeColour(const color: TColor): tcolor;
function colourtogray(const colour: cardinal): cardinal;
function AntiAlias_S2(Bitmap: tbitmap; BGColour: TColor): TBitmap;
procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer; Source, Dest: TSelectArea); overload;
procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer; Source, Dest: TSelectArea; BackGround: byte); overload;

// Frame Image Drawing
procedure DrawFrameImageWithShadow(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
procedure DrawShadowWithFrameImage(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
procedure DrawFrameImage(var SHP: TSHP; var Shadow_Match: TShadowMatch; Frame, Zoom: integer; Flood, Grayscale, Preview: boolean; var Palette: TPalette; var Image: TImage);
procedure AssignBitmapToImage(var Bitmap: TBitmap; Image: TImage);

 // Drawing Procedures/Functions
 // Misc
function CreateBmpArray(var Bmp: array of TBitmap; var SHP: TSHP; ShadowType: integer; FrameRange: boolean; StartFrame, EndFrame: integer; Shadow_Match: TShadowMatch; SHPPalette: TPalette; Zoom: integer): integer;
function CreateTextureDataPointer(SHP: TSHP; FrameStart, FrameEnd: integer; Palette: TPalette; var Width, Height, InRow, NumRows: integer): Pointer;

implementation


uses FormMain;

function ColourToTRGB32(const Colour: Tcolor): TRGB32;
begin
   Result.R := GetRValue(Colour);
   Result.G := GetGValue(Colour);
   Result.B := GetBValue(Colour);
end;

function OpositeColour(const Color: TColor): TColor;
var
   r, g, b:   byte;
   NewColour: TColor;
begin
   R := 255 - GetRValue(Color);
   G := 255 - GetGValue(Color);
   B := 255 - GetBValue(Color);

   NewColour := RGB(R, G, B);

   // If Same Colour then Pick Another.
   if (R = GetRValue(Color)) or (G = GetGValue(Color)) or (B = GetBValue(Color)) then
      NewColour := RGB(R + (GetRValue(color) div 2), G + (GetGValue(color) div 2), B + (GetBValue(color) div 2));

   // Fixes Prob With Gray On UnitTem.pal
   if ((R > 120) and (R < 130)) or ((G > 120) and (G < 130)) or ((B > 120) and (B < 130)) then
      NewColour := RGB(R + (GetRValue(color) div 2), G + (GetGValue(color) div 2), B + (GetBValue(color) div 2));

   Result := NewColour;
end;

// Turns a colour to grayscale
function colourtogray(const colour: cardinal): cardinal;
var
   temp: char;
begin
   temp   := char((GetBValue(colour) * 29 + GetGValue(colour) * 150 + GetRValue(colour) * 77) div 256);
   Result := RGB(Ord(temp), Ord(temp), Ord(temp));
end;

// Frame Image Drawing

procedure DrawFrameImage(var SHP: TSHP; var Shadow_Match: TShadowMatch; Frame, Zoom: integer; Flood, Grayscale, Preview: boolean; var Palette: TPalette; var Image: TImage);
var
   x, y:   word;
   Bitmap: TBitmap;
begin
   Bitmap := TBitmap.Create;

   Image.Picture.Bitmap.Width := SHP.header.Width * zoom;
   Image.Picture.Bitmap.Height := SHP.header.Height * zoom;

   Bitmap.Width  := image.Picture.Bitmap.Width;
   Bitmap.Height := image.Picture.Bitmap.Height;

   // Clear the image of colour (fills with the transparent colour)
   if flood then // Only clear image if flood is set to true
   begin
      Bitmap.Canvas.Brush.Color := palette[TRANSPARENT];
      Bitmap.Canvas.FillRect(rect(0, 0, SHP.header.Width * zoom, SHP.header.Height * zoom));
   end
   else
   begin
      Bitmap.Canvas.Draw(0, 0, Image.Picture.Bitmap);
   end;

   // Populate the image pixel by pixel
   for y := 0 to SHP.header.Height - 1 do
      for x := 0 to SHP.header.Width - 1 do
      begin
         if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
         begin
            if grayscale then
               Bitmap.Canvas.Brush.Color := Shadow_Match[shp.Data[Frame].frameimage[x, y]].Original// colourtogray(palette[shp.data[Frame].frameimage[x,y]])
            else
            begin
               Bitmap.Canvas.Brush.Color := palette[shp.Data[Frame].frameimage[x, y]];
            end;

            Bitmap.Canvas.FillRect(Rect((x * zoom), (y * zoom), (x * zoom) + zoom, (y * zoom) + zoom));
         end;
      end;

   Image.Canvas.Draw(0, 0, Bitmap);
   Bitmap.Free;
end;

procedure DrawFrameImageWithShadow(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
begin
   DrawFrameImage(SHP, Shadow_Match, GetShadowFromOposite(SHP, Frame), Zoom, True, False, Preview, Palette, Image); // Draw Shadow
   DrawFrameImage(SHP, Shadow_Match, Frame, Zoom, False, GrayScale, Preview, Palette, Image); //Draw Owner
end;

procedure DrawShadowWithFrameImage(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
begin
   DrawFrameImage(SHP, Shadow_Match, Frame, Zoom, True, False, Preview, Palette, Image); // Draw Shadow
   DrawFrameImage(SHP, Shadow_Match, GetShadowOposite(SHP, frame), Zoom, False, GrayScale, Preview, Palette, Image); //Draw Owner
end;

// 3.35: Draw on Bitmap, by Stucuk
procedure DrawFrameImageToBMP(var SHP: TSHP; var Shadow_Match: TShadowMatch; Frame, Zoom: integer; Flood, Grayscale: boolean; var Palette: TPalette; var Image: TBitmap);
var
   x, y: word;
begin
   //BANSHEE LEAVE THIS HERE THINGS ACTUALY NEED IT!
   Image.Width  := SHP.header.Width * zoom;
   Image.Height := SHP.header.Height * zoom;

   // Clear the image of colour (fills with the transparent colour)
   if flood then // Only clear image if flood is set to true
   begin
      Image.Canvas.Brush.Color := palette[TRANSPARENT];
      Image.Canvas.FillRect(rect(0, 0, SHP.header.Width * zoom, SHP.header.Height * zoom));
   end;

   // Populate the image pixel by pixel
   if zoom > 1 then
   begin
      for y := 0 to SHP.header.Height - 1 do
         for x := 0 to SHP.header.Width - 1 do
         begin
            if grayscale then
            begin
               Image.Canvas.Brush.Color := Shadow_Match[shp.Data[Frame].frameimage[x, y]].Original;// colourtogray(palette[shp.data[Frame].frameimage[x,y]])
            end
            else
            begin
               Image.Canvas.Brush.Color := palette[shp.Data[Frame].frameimage[x, y]];
            end;

            if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
               // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
               Image.Canvas.FillRect(Rect((x * zoom), (y * zoom), (x * zoom) + zoom, (y * zoom) + zoom));
         end
   end
   else
   begin
      for y := 0 to SHP.header.Height - 1 do
         for x := 0 to SHP.header.Width - 1 do
         begin
            if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
               // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
               if grayscale then
                  Image.Canvas.Pixels[x, y] := Shadow_Match[shp.Data[Frame].frameimage[x, y]].Original// colourtogray(palette[shp.data[Frame].frameimage[x,y]])
               else
                  Image.Canvas.Pixels[x, y] := palette[shp.Data[Frame].frameimage[x, y]];
         end;
   end;
end;

procedure DrawFrameImageWithShadowToBMP(var SHP: TSHP; Frame, Zoom: integer; Grayscale: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TBitmap);
begin
   DrawFrameImageToBMP(SHP, Shadow_Match, GetShadowFromOposite(SHP, Frame), Zoom, True, False, Palette, Image); // Draw Shadow
   DrawFrameImageToBMP(SHP, Shadow_Match, Frame, Zoom, False, GrayScale, Palette, Image); //Draw Owner
end;

procedure DrawShadowWithFrameImageToBMP(var SHP: TSHP; Frame, Zoom: integer; Grayscale: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TBitmap);
begin
   DrawFrameImageToBMP(SHP, Shadow_Match, Frame, Zoom, True, False, Palette, Image); // Draw Shadow
   DrawFrameImageToBMP(SHP, Shadow_Match, GetShadowOposite(SHP, frame), Zoom, False, GrayScale, Palette, Image); //Draw Owner
end;

// Modifyed ver of AntiAliasRect from janFX by Jan Verhoeven
function AntiAlias_S2(Bitmap: tbitmap; BGColour: TColor): TBitmap;
var
   x, y: integer;
   p0, p1, p2, r1: pbytearray;
   p01, p02, p03, p21, p22, p23, p31, p32, p33, p41, p42, p43: byte;
begin
   Bitmap.PixelFormat := pf24bit;
   Result := TBitmap.Create;
   Result.Width := Bitmap.Width;
   Result.Height := Bitmap.Height;
   Result.PixelFormat := pf24bit;

   Result.Canvas.Brush.Color := BGColour;
   Result.Canvas.FillRect(Rect(0, 0, Result.Width, Result.Height));

   for y := 1 to Result.Height - 2 do
   begin
      p0 := Bitmap.ScanLine[y - 1];
      p1 := Bitmap.scanline[y];
      p2 := Bitmap.ScanLine[y + 1];
      r1 := Result.ScanLine[y];
      for x := 1 to Result.Width - 2 do
         if RGB(p1[x * 3 + 2], p1[x * 3 + 1], p1[x * 3]) <> BGColour then
         begin
            // Should stop BG Interfearence
            if RGB(p0[x * 3 + 2], p0[x * 3 + 1], p0[x * 3]) <> BGColour then
            begin
               p01 := p0[x * 3];
               p02 := p0[x * 3 + 1];
               p03 := p0[x * 3 + 2];
            end
            else
            begin
               p01 := p1[x * 3];
               p02 := p1[x * 3 + 1];
               p03 := p1[x * 3 + 2];
            end;

            // Should stop BG Interfearence
            if RGB(p2[x * 3 + 2], p2[x * 3 + 1], p2[x * 3]) <> BGColour then
            begin
               p21 := p2[x * 3];
               p22 := p2[x * 3 + 1];
               p23 := p2[x * 3 + 2];
            end
            else
            begin
               p21 := p1[x * 3];
               p22 := p1[x * 3 + 1];
               p23 := p1[x * 3 + 2];
            end;

            // Should stop BG Interfearence
            if RGB(p1[(x - 1) * 3 + 2], p1[(x - 1) * 3 + 1], p1[(x - 1) * 3]) <> BGColour then
            begin
               p31 := p1[(x - 1) * 3];
               p32 := p1[(x - 1) * 3 + 1];
               p33 := p1[(x - 1) * 3 + 2];
            end
            else
            begin
               p31 := p1[x * 3];
               p32 := p1[x * 3 + 1];
               p33 := p1[x * 3 + 2];
            end;

            // Should stop BG Interfearence
            if RGB(p1[(x + 1) * 3 + 2], p1[(x + 1) * 3 + 1], p1[(x + 1) * 3]) <> BGColour then
            begin
               p41 := p1[(x + 1) * 3];
               p42 := p1[(x + 1) * 3 + 1];
               p43 := p1[(x + 1) * 3 + 2];
            end
            else
            begin
               p41 := p1[x * 3];
               p42 := p1[x * 3 + 1];
               p43 := p1[x * 3 + 2];
            end;

            r1[x * 3]     := (p01 + p21 + p31 + p41) div 4;
            r1[x * 3 + 1] := (p02 + p22 + p32 + p42) div 4;
            r1[x * 3 + 2] := (p03 + p23 + p33 + p43) div 4;
         end;
   end;
end;

procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer; Source, Dest: TSelectArea);
var
   x, y, XDifference, YDifference: integer;
   FrameImage: TFrameImage;
begin
   // Get the differences to find out the size of the source square
   XDifference := Max(Source.X1, Source.X2) - Min(Source.X1, Source.X2);
   YDifference := Max(Source.Y1, Source.Y2) - Min(Source.Y1, Source.Y2);

   // Set the size of the temporary FrameImage
   SetLength(FrameImage, SHP.Header.Width, SHP.Header.Height);

   // Clear the pixels inside the source square
   for x := 0 to SHP.Header.Width - 1 do
      for y := 0 to SHP.Header.Height - 1 do
         if (x >= Min(Source.X1, Source.X2)) and (x <= Max(Source.X1, Source.X2)) and (y >= Min(Source.Y1, Source.Y2)) and (y < Max(Source.Y1, Source.Y2)) then
            FrameImage[x, y] := 0
         else
            FrameImage[x, y] := SHP.Data[Frame].FrameImage[x, y];

   // Copy Source pixels to destiny.
   for x := 0 to XDifference - 1 do
      for y := 0 to YDifference - 1 do
         // Check Destination in the SHP range
         if ((Min(Dest.X1, Dest.X2) + x) < SHP.Header.Width) and ((Min(Dest.Y1, Dest.Y2) + y) < SHP.Header.Height) then
            if ((Min(Dest.X1, Dest.X2) + x) >= 0) and ((Min(Dest.Y1, Dest.Y2) + y) >= 0) then
            begin
               // Check if Source is in the SHP range
               if ((Min(Source.X1, Source.X2) + x) < SHP.Header.Width) and ((Min(Source.Y1, Dest.Y2) + y) < SHP.Header.Height) and ((Min(Source.X1, Source.X2) + x) >= 0) and ((Min(Source.Y1, Source.Y2) + y) >= 0) then
                  // Check its in range
                  // Copy source pixel to the equivalent destiny pixel
                  FrameImage[Min(Dest.X1, Dest.X2) + x, Min(Dest.Y1, Dest.Y2) + y] := SHP.Data[Frame].FrameImage[Min(Source.X1, Source.X2) + x, Min(Source.Y1, Source.Y2) + y]
               else
                  FrameImage[Min(Dest.X1, Dest.X2) + x, Min(Dest.Y1, Dest.Y2) + y] := 0;
               // Source is out of bounds, defult to 0;
            end;

   // Copy FrameImage to the official FrameImage.
   SHP.Data[Frame].FrameImage := Copy(FrameImage);
end;

procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer; Source, Dest: TSelectArea; BackGround: byte);
var
   x, y, XDifference, YDifference: integer;
   FrameImage: TFrameImage;
begin
   // Get the differences to find out the size of the source square
   XDifference := Max(Source.X1, Source.X2) - Min(Source.X1, Source.X2);
   YDifference := Max(Source.Y1, Source.Y2) - Min(Source.Y1, Source.Y2);

   // Set the size of the temporary FrameImage
   SetLength(FrameImage, SHP.Header.Width, SHP.Header.Height);

   // Clear the pixels inside the source square
   for x := 0 to SHP.Header.Width - 1 do
      for y := 0 to SHP.Header.Height - 1 do
         if (x >= Min(Source.X1, Source.X2)) and (x <= Max(Source.X1, Source.X2)) and (y >= Min(Source.Y1, Source.Y2)) and (y < Max(Source.Y1, Source.Y2)) then
            FrameImage[x, y] := 0
         else
            FrameImage[x, y] := SHP.Data[Frame].FrameImage[x, y];

   // Copy Source pixels to destiny.
   for x := 0 to XDifference - 1 do
      for y := 0 to YDifference - 1 do
         // Check Destination in the SHP range
         if ((Min(Dest.X1, Dest.X2) + x) < SHP.Header.Width) and ((Min(Dest.Y1, Dest.Y2) + y) < SHP.Header.Height) then
            if ((Min(Dest.X1, Dest.X2) + x) >= 0) and ((Min(Dest.Y1, Dest.Y2) + y) >= 0) then
            begin
               // Check if Source is in the SHP range
               if ((Min(Source.X1, Source.X2) + x) < SHP.Header.Width) and ((Min(Source.Y1, Dest.Y2) + y) < SHP.Header.Height) and ((Min(Source.X1, Source.X2) + x) >= 0) and ((Min(Source.Y1, Source.Y2) + y) >= 0) then
               begin
                  // Check its in range
                  if SHP.Data[Frame].FrameImage[Min(Source.X1, Source.X2) + x, Min(Source.Y1, Source.Y2) + y] <> 0 then
                     // Copy source pixel to the equivalent destiny pixel
                     FrameImage[Min(Dest.X1, Dest.X2) + x, Min(Dest.Y1, Dest.Y2) + y] := SHP.Data[Frame].FrameImage[Min(Source.X1, Source.X2) + x, Min(Source.Y1, Source.Y2) + y];
               end
               else
                  FrameImage[Min(Dest.X1, Dest.X2) + x, Min(Dest.Y1, Dest.Y2) + y] := 0;
               // Source is out of bounds, default to 0;
            end;

   // Copy FrameImage to the official FrameImage.
   SHP.Data[Frame].FrameImage := Copy(FrameImage);
end;

procedure AssignBitmapToImage(var Bitmap: TBitmap; Image: TImage);
begin
   Image.picture.Bitmap.Width  := Bitmap.Width;
   Image.picture.Bitmap.Height := Bitmap.Height;
   Image.picture.Bitmap.Canvas.Draw(0, 0, Bitmap);
   Bitmap.Free;
end;

function CreateBmpArray(var Bmp: array of TBitmap; var SHP: TSHP; ShadowType: integer; FrameRange: boolean; StartFrame, EndFrame: integer; Shadow_Match: TShadowMatch; SHPPalette: TPalette; Zoom: integer): integer;
var
   X, SF, SE, Length: integer;
begin
   // Detect length by checking if it uses shadows or not.
   if ShadowType = 0 then
      Length := SHP.Header.NumImages
   else
      Length := SHP.Header.NumImages div 2;

   // Detect range
   if FrameRange then
   begin
      SF := StartFrame;
      SE := EndFrame;
   end
   else
   begin
      SF := 1;// 1???
      SE := Length;
   end;

   // Write result
   Result := SE - SF + 1;
   // Build bitmaps.
   for x := SF to SE do
   begin
      bmp[x - SF] := TBitmap.Create;
      bmp[x - SF].TransparentColor := SHPPalette[0];
      if ShadowType = 2 then
         DrawFrameImageWithShadowToBMP(SHP, x, Zoom, False, SHPPalette, Shadow_Match, bmp[x - SF])
      else
         DrawFrameImageToBMP(SHP, Shadow_Match, x, Zoom, True, False, SHPPalette, bmp[x - SF]);
   end;
end;

procedure AddColour(R, G, B, A: byte; var P: Pointer);
begin
   byte(P^) := R;
   Inc(integer(P));
   byte(P^) := G;
   Inc(integer(P));
   byte(P^) := B;
   Inc(integer(P));
   byte(P^) := A;
   Inc(integer(P));
end;

type
   TColour = record
      R, G, B, A: byte;
   end;

function ColorToTColour(Color: TColor): TColour;
begin
   Result.R := GetRValue(Color);
   Result.G := GetGValue(Color);
   Result.B := GetBValue(Color);
   Result.A := 255;

end;

procedure AddFrameRow(SHP: TSHP; Palette: TPalette; Frame, y: integer; var P: Pointer);
var
   x:      integer;
   Colour: TColour;
begin
   for x := SHP.header.Width - 1 downto 0 do
   begin
      if (frame > 0) and (shp.Data[Frame].frameimage[x, y] <> TRANSPARENT) then
         Colour := ColorToTColour(palette[shp.Data[Frame].frameimage[x, y]])
      else
      begin
         Colour.R := 0;
         Colour.G := 0;
         Colour.B := 252;
         Colour.A := 0;
      end;
      AddColour(Colour.R, Colour.G, Colour.B, Colour.A, P);
   end;
end;


function CreateTextureDataPointer(SHP: TSHP; FrameStart, FrameEnd: integer; Palette: TPalette; var Width, Height, InRow, NumRows: integer): Pointer;
var
   x, y, Frame, c: integer;
   P: Pointer;
begin
   Width  := SHP.header.Width * (FrameEnd - FrameStart + 1);
   Height := SHP.header.Height;
   InRow  := FrameEnd - FrameStart + 1;

   if Width > 64 * 64 then
   begin
      InRow := Trunc((64 * 64) / (SHP.header.Width));
      //FrameEnd := FrameStart + InRow-1;
      Width := SHP.header.Width * (InRow);
      SetRoundMode(rmUp);
      NumRows := Round((FrameEnd - FrameStart + 1) / InRow);
      Height  := (NumRows) * SHP.header.Height;
      SetRoundMode(rmNearest);
   end;

   GetMem(Result, Width * Height * 4);
   //addr
   P     := Addr(integer(Result^));
   Frame := FrameStart + 1;
   C     := 0;

   repeat
      for y := SHP.header.Height - 1 downto 0 do
         for x := 0 to InRow - 1 do
         begin
            if Frame + x + c > FrameEnd then
               AddFrameRow(SHP, Palette, 0, y, P) // add fake image to fill gaps
            else
               AddFrameRow(SHP, Palette, Frame + x + c, y, P);
         end;
      Inc(C, InRow);
   until C >= FrameEnd - FrameStart + 1;
end;


end.
