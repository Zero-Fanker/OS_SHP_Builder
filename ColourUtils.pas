unit ColourUtils;

// This unit contains functions to convert colours into different representations

// Most of the code is inspired in the following places:
// - http://www.brucelindbloom.com/index.html?Equations.html
// - for YIQ: http://www2.ic.uff.br/~aconci/trab2~1.htm
// - Wikipedia
// - and our ICC whitepoint comes from http://www.mathworks.com/help/images/ref/whitepoint.html

interface

type
   TColourUtils = class
      const
         C_MULT_I = 255 / (2 * 0.596);
         C_MULT_Q = 255 / (2 * 0.523);
         // Illuminant ICC (approximation to D50)
         C_CIE_E_X = 1;
         C_CIE_E_Y = 1;
         C_CIE_E_Z = 1;
         C_ICC_X = 0.9642;
         C_ICC_Y = 1;
         C_ICC_Z = 0.8249;
         C_WHITE_X = C_CIE_E_X;
         C_WHITE_Y = C_CIE_E_Y;
         C_WHITE_Z = C_CIE_E_Z;
         // CIE constants
         C_CIE_EPSILON = 216 / 24839;
         C_CIE_KAPPA = 24389 / 27;
         C_CIE_KAPPA_EPSILON = C_CIE_KAPPA * C_CIE_EPSILON;
      public
         // RGB
         procedure RGBtoXYZ(const _r, _g, _b: byte; var _x, _y, _z: real);
         procedure RGBtoYIQBand(const _r, _g, _b: byte; var _by, _bi, _bq : byte);
         procedure RGBtoYIQ(const _r, _g, _b: byte; var _y, _i, _q : real);
         procedure RGBtoLAB(const _r, _g, _b: byte; var __l, __a, __b : real);
         procedure RGBtoLCHab(const _r, _g, _b: byte; var _l, _c, _h : real);
         procedure RGBtoLUV(const _r, _g, _b: byte; var _l, _u, _v : real);
         procedure RGBtoLCHuv(const _r, _g, _b: byte; var _l, _c, _h : real);

         // XYZ
         procedure XYZtoRGB(const _x, _y, _z: real; var _r, _g, _b: byte);
         procedure XYZtoYIQ(const _x, _y, _z: real; var __y, __i, __q: real);
         procedure XYZtoLAB(const _x, _y, _z: real; var _l, _a, _b: real);
         procedure XYZtoLCHab(const _x, _y, _z: real; var _l, _c, _h: real);
         procedure XYZtoLUV(const _x, _y, _z: real; var _l, _u, _v: real);
         procedure XYZtoLCHuv(const _x, _y, _z: real; var _l, _c, _h: real);

         // YIQ
         procedure YIQtoRGB(const _y, _i, _q: real; var _r, _g, _b: byte);
         procedure YIQtoXYZ(const _y, _i, _q: real; var __x, __y, __z: real);
         procedure YIQtoBand(const _y, _i, _q: real; var _by, _bi, _bq: byte);
         procedure YIQtoLAB(const _y, _i, _q: real; var _l, _a, _b: real);
         procedure YIQtoLCHab(const _y, _i, _q: real; var _l, _c, _h: real);
         procedure YIQtoLUV(const _y, _i, _q: real; var _l, _u, _v: real);
         procedure YIQtoLCHuv(const _y, _i, _q: real; var _l, _c, _h: real);

         // LAB
         procedure LABtoXYZ(const _l, _a, _b: real; var _x, _y, _z: real);
         procedure LABtoRGB(const _l, _a, _b: real; var __r, __g, __b: byte);
         procedure LABtoYIQ(const _l, _a, _b: real; var _y, _i, _q: real);
         procedure LABtoLCHab(const _l, _a, _b: real; var __l, __c, __h: real);
         procedure LABtoLUV(const _l, _a, _b: real; var __l, __u, __v: real);
         procedure LABtoLCHuv(const _l, _a, _b: real; var __l, __c, __h: real);

         // LCH(ab)
         procedure LCHabtoXYZ(const _l, _c, _h: real; var _x, _y, _z: real);
         procedure LCHabtoRGB(const _l, _c, _h: real; var _r, _g, _b: byte);
         procedure LCHabtoYIQ(const _l, _c, _h: real; var _y, _i, _q: real);
         procedure LCHabtoLAB(const _l, _c, _h: real; var __l, __a, __b: real);
         procedure LCHabtoLUV(const _l, _c, _h: real; var __l, __u, __v: real);
         procedure LCHabtoLCHuv(const _l, _c, _h: real; var __l, __c, __h: real);

         // Luv
         procedure LUVtoXYZ(const _l, _u, _v: real; var _x, _y, _z: real);
         procedure LUVtoRGB(const _l, _u, _v: real; var _r, _g, _b: byte);
         procedure LUVtoYIQ(const _l, _u, _v: real; var _y, _i, _q: real);
         procedure LUVtoLAB(const _l, _u, _v: real; var __l, __a, __b: real);
         procedure LUVtoLCHab(const _l, _u, _v: real; var __l, __c, __h: real);
         procedure LUVtoLCHuv(const _l, _u, _v: real; var __l, __c, __h: real);

         // LCH(uv)
         procedure LCHuvtoXYZ(const _l, _c, _h: real; var _x, _y, _z: real);
         procedure LCHuvtoRGB(const _l, _c, _h: real; var _r, _g, _b: byte);
         procedure LCHuvtoYIQ(const _l, _c, _h: real; var _y, _i, _q: real);
         procedure LCHuvtoLAB(const _l, _c, _h: real; var __l, __a, __b: real);
         procedure LCHuvtoLCHab(const _l, _c, _h: real; var __l, __c, __h: real);
         procedure LCHuvtoLUV(const _l, _c, _h: real; var __l, __u, __v: real);
   end;

implementation

uses Math;

procedure TColourUtils.RGBtoXYZ(const _r, _g, _b: byte; var _x, _y, _z: real);
var
   r,g,b: real;
begin
   r := _r / 255;
   g := _g / 255;
   b := _b / 255;

   if r > 0.04045 then
   begin
      r := Power((r + 0.055) / 1.055, 2.4);
   end
   else
   begin
      r := r / 12.92;
   end;

   if g > 0.04045 then
   begin
      g := Power((g + 0.055) / 1.055, 2.4);
   end
   else
   begin
      g := g / 12.92;
   end;

   if b > 0.04045 then
   begin
      b := Power((b + 0.055) / 1.055, 2.4);
   end
   else
   begin
      b := b / 12.92;
   end;

   _x := ((r * 0.4887180) + (g * 0.3106803) + (b * 0.2006017));
   _y := ((r * 0.1762044) + (g * 0.8129847) + (b * 0.0108109));
   _z := ((g * 0.0102048) + (b * 0.9897952));
end;

procedure TColourUtils.RGBtoYIQBand (const _r, _g, _b: byte; var _by, _bi, _bq: byte);
var
   y,i,q: real;
begin
   RGBtoYIQ(_r, _g, _b, y, i, q);
   YIQtoBand(y, i, q, _by, _bi, _bq);
end;

procedure TColourUtils.RGBtoYIQ (const _r, _g, _b: byte; var _y, _i, _q : real);
var
   r, g, b: real;
begin
   r := _r / 255;
   g := _g / 255;
   b := _b / 255;

   _y := (0.299 * r) + (0.587 * g) + (0.114 * b);
   _i := (0.596 * r) - (0.275 * g) - (0.321 * b);
   _q := (0.212 * r) - (0.523 * g) + (0.311 * b);
end;

procedure TColourUtils.RGBtoLAB(const _r, _g, _b: byte; var __l, __a, __b : real);
var
   x,y,z: real;
begin
   RGBtoXYZ(_r, _g, _b, x, y, z);
   XYZtoLAB(x, y, z, __l, __a, __b);
end;

procedure TColourUtils.RGBtoLCHab(const _r, _g, _b: byte; var _l, _c, _h : real);
var
   l, a, b: real;
begin
   RGBtoLAB(_r, _g, _b, l, a, b);
   LABtoLCHab(l, a, b, _l, _c, _h);
end;

procedure TColourUtils.RGBtoLUV(const _r, _g, _b: byte; var _l, _u, _v : real);
var
   x,y,z: real;
begin
   RGBtoXYZ(_r, _g, _b, x, y, z);
   XYZtoLUV(x, y, z, _l, _u, _v);
end;

procedure TColourUtils.RGBtoLCHuv(const _r, _g, _b: byte; var _l, _c, _h : real);
var
   l, u, v: real;
begin
   RGBtoLUV(_r, _g, _b, l, u, v);
   LUVtoLCHuv(l, u, v, _l, _c, _h);
end;

procedure TColourUtils.XYZtoRGB(const _x, _y, _z: real; var _r, _g, _b: byte);
var
   r, g, b: real;
begin
   r := (_x * 0.41847) - (_y * 0.15866) - (_z * 0.082835);
   g := (_x * -0.091169) + (_y * 0.25243) + (_z * 0.015708);
   b := (_x * 0.0009209) - (_y * 0.0025498) + (_z * 0.1786);

   if r > 0.0031308 then
   begin
      r := 1.055 * Power(r, 1 / 2.4) - 0.055;
   end
   else
   begin
      r := 12.92 * r;
   end;
   if g > 0.0031308 then
   begin
      g := 1.055 * Power(g, 1 / 2.4) - 0.055;
   end
   else
   begin
      g := 12.92 * g;
   end;
   if b > 0.0031308 then
   begin
      b := 1.055 * Power(b, 1 / 2.4) - 0.055;
   end
   else
   begin
      b := 12.92 * b;
   end;

   r := 255 * r;
   if r >= 255 then
      r := 255;
   g := 255 * g;
   if g >= 255 then
      g := 255;
   b := 255 * b;
   if b >= 255 then
      b := 255;

   _r := Round(r);
   _g := Round(g);
   _b := Round(b);
end;

procedure TColourUtils.XYZtoYIQ(const _x, _y, _z: real; var __y, __i, __q: real);
var
   r, g, b: byte;
begin
   XYZtoRGB(_x, _y, _z, r, g, b);
   RGBtoYIQ(r, g, b, __y, __i, __q);
end;

procedure TColourUtils.XYZtoLAB(const _x, _y, _z: real; var _l, _a, _b: real);
var
   x,y,z,fx, fy, fz: real;
begin
   x := _x / C_WHITE_X;
   y := _y / C_WHITE_Y;
   z := _z / C_WHITE_Z;
   if x > C_CIE_EPSILON then
   begin
      fx := Power(x, 1/3);
   end
   else
   begin
      fx := ((x * C_CIE_KAPPA) + 16) / 116;
   end;
   if y > C_CIE_EPSILON then
   begin
      fy := Power(y, 1/3);
   end
   else
   begin
      fy := ((y * C_CIE_KAPPA) + 16) / 116;
   end;
   if z > C_CIE_EPSILON then
   begin
      fz := Power(z, 1/3);
   end
   else
   begin
      fz := ((z * C_CIE_KAPPA) + 16) / 116;
   end;
   _l := (116 * fy) - 16;
   _a := 500 * (fx - fy);
   _b := 200 * (fy - fz);
end;

procedure TColourUtils.XYZtoLCHab(const _x, _y, _z: real; var _l, _c, _h: real);
var
   l,a,b: real;
begin
   XYZtoLAB(_x, _y, _z, l, a, b);
   LABtoLCHab(l, a, b, _l, _c, _h);
end;

procedure TColourUtils.XYZtoLUV(const _x, _y, _z: real; var _l, _u, _v: real);
var
   upr, vpr, up, vp, yr: real;
begin
   upr := (4 * C_WHITE_X) / (C_WHITE_X + (C_WHITE_Y * 15) + (3 * C_WHITE_Z));
   vpr := (9 * C_WHITE_Y) / (C_WHITE_X + (C_WHITE_Y * 15) + (3 * C_WHITE_Z));
   up := (4 * _x) / (_x + (_y * 15) + (3 * _z));
   vp := (9 * _y) / (_x + (_y * 15) + (3 * _z));
   yr := _y / C_WHITE_Y;

   if yr > C_CIE_EPSILON then
   begin
      _l := (116 * Power(yr, 1/3)) - 16;
   end
   else
   begin
      _l := yr * C_CIE_KAPPA;
   end;
   _u := 13 * _l * (up - upr);
   _v := 13 * _l * (vp - vpr);
end;

procedure TColourUtils.XYZtoLCHuv(const _x, _y, _z: real; var _l, _c, _h: real);
var
   l, u, v: real;
begin
   XYZtoLUV(_x, _y, _z, l, u, v);
   LUVtoLCHuv(l, u, v, _l, _c, _h);
end;

procedure TColourUtils.YIQtoRGB(const _y, _i, _q: real; var _r, _g, _b: byte);
begin
   _r := Round(255 * ((_y * 1.0028) + (_i * 0.9544) + (_q * 0.6178)));
   _g := Round(255 * ((_y * 0.9965) - (_i * 0.2705) - (_q * 0.6445)));
   _b := Round(255 * ((_y * 1.0083) - (_i * 1.1101) + (_q * 1.6992)));
end;

procedure TColourUtils.YIQtoXYZ(const _y, _i, _q: real; var __x, __y, __z: real);
var
   r, g, b: byte;
begin
   YIQtoRGB(_y, _i, _q, r, g, b);
   RGBtoXYZ(r, g, b, __x, __y, __z);
end;

procedure TColourUtils.YIQtoBand(const _y, _i, _q: real; var _by, _bi, _bq: byte);
begin
   _by := Round(_y * 255);
   _bi := Round((_i + 0.596) * C_MULT_I);
   _bq := Round((_q + 0.523) * C_MULT_Q);
end;

procedure TColourUtils.YIQtoLAB(const _y, _i, _q: real; var _l, _a, _b: real);
var
   x, y, z: real;
begin
   YIQtoXYZ(_y, _i, _q, x, y, z);
   XYZtoLAB(x, y, z, _l, _a, _b);
end;

procedure TColourUtils.YIQtoLCHab(const _y, _i, _q: real; var _l, _c, _h: real);
var
   x, y, z: real;
begin
   YIQtoXYZ(_y, _i, _q, x, y, z);
   XYZtoLCHab(x, y, z, _l, _c, _h);
end;

procedure TColourUtils.YIQtoLUV(const _y, _i, _q: real; var _l, _u, _v: real);
var
   x, y, z: real;
begin
   YIQtoXYZ(_y, _i, _q, x, y, z);
   XYZtoLUV(x, y, z, _l, _u, _v);
end;

procedure TColourUtils.YIQtoLCHuv(const _y, _i, _q: real; var _l, _c, _h: real);
var
   x, y, z: real;
begin
   YIQtoXYZ(_y, _i, _q, x, y, z);
   XYZtoLCHuv(x, y, z, _l, _c, _h);
end;

procedure TColourUtils.LABtoXYZ(const _l, _a, _b: real; var _x, _y, _z: real);
var
   fx, fy, fz, xr, yr, zr: real;
begin
   fy := (_l + 16) / 116;
   fz := fy - (_b / 200);
   fx := (_a / 500) + fy;
   xr := fx * fx * fx;
   if xr <= C_CIE_EPSILON then
   begin
      xr := (((fx * 116) - 16) / C_CIE_KAPPA);
   end;
   if _l > C_CIE_KAPPA_EPSILON then
   begin
      yr := Power(((_l + 16) / 116), 3);
   end
   else
   begin
      yr := _l / C_CIE_KAPPA;
   end;
   zr := fz * fz * fz;
   if zr <= C_CIE_EPSILON then
   begin
      zr := (((fz * 116) - 16) / C_CIE_KAPPA);
   end;
   _x := xr * C_WHITE_X;
   _y := yr * C_WHITE_Y;
   _z := zr * C_WHITE_Z;
end;

procedure TColourUtils.LABtoRGB(const _l, _a, _b: real; var __r, __g, __b: byte);
var
   x,y,z: real;
begin
   LABtoXYZ(_l, _a, _b, x, y, z);
   XYZtoRGB(x, y, z, __r, __g, __b);
end;

procedure TColourUtils.LABtoYIQ(const _l, _a, _b: real; var _y, _i, _q: real);
var
   x,y,z: real;
begin
   LABtoXYZ(_l, _a, _b, x, y, z);
   XYZtoYIQ(x, y, z, _y, _i, _q);
end;

procedure TColourUtils.LABtoLCHab(const _l, _a, _b: real; var __l, __c, __h: real);
begin
   __l := _l;
   __c := sqrt((_a * _a) + (_b * _b));
   if _a <> 0 then
   begin
      __h := ArcTan2(_b, _a);
   end
   else
   begin
      if _b > 0 then
      begin
         __h := pi;
      end
      else
      begin
         __h := -pi;
      end;
   end;
end;

procedure TColourUtils.LABtoLUV(const _l, _a, _b: real; var __l, __u, __v: real);
var
   x, y, z: real;
begin
   LABtoXYZ(_l, _a, _b, x, y, z);
   XYZtoLUV(x, y, z, __l, __u, __v);
end;

procedure TColourUtils.LABtoLCHuv(const _l, _a, _b: real; var __l, __c, __h: real);
var
   l, u, v: real;
begin
   LABtoLUV(_l, _a, _b, l, u, v);
   LUVtoLCHuv(l, u, v, __l, __c, __h);
end;

procedure TColourUtils.LCHabtoLAB(const _l, _c, _h: real; var __l, __a, __b: real);
begin
   __l := _l;
   __a := _c * cos(_h);
   __b := _c * sin(_h);
end;

procedure TColourUtils.LCHabtoXYZ(const _l, _c, _h: real; var _x, _y, _z: real);
var
   l,a,b: real;
begin
   LCHabtoLAB(_l, _c, _h, l, a, b);
   LABtoXYZ(l, a, b, _x, _y, _z);
end;

procedure TColourUtils.LCHabtoRGB(const _l, _c, _h: real; var _r, _g, _b: byte);
var
   x,y,z: real;
begin
   LCHabtoXYZ(_l, _c, _h, x, y, z);
   XYZtoRGB(x, y, z, _r, _g, _b);
end;

procedure TColourUtils.LCHabtoYIQ(const _l, _c, _h: real; var _y, _i, _q: real);
var
   x,y,z: real;
begin
   LCHabtoXYZ(_l, _c, _h, x, y, z);
   XYZtoYIQ(x, y, z, _y, _i, _q);
end;

procedure TColourUtils.LCHabtoLUV(const _l, _c, _h: real; var __l, __u, __v: real);
var
   x,y,z: real;
begin
   LCHabtoXYZ(_l, _c, _h, x, y, z);
   XYZtoLUV(x, y, z, __l, __u, __v);
end;

procedure TColourUtils.LCHabtoLCHuv(const _l, _c, _h: real; var __l, __c, __h: real);
var
   l, u, v: real;
begin
   LCHabtoLUV(_l, _c, _h, l, u, v);
   LUVtoLCHuv(l, u, v, __l, __c, __h);
end;

procedure TColourUtils.LUVtoXYZ(const _l, _u, _v: real; var _x, _y, _z: real);
var
   u0, v0, a, b, c, d: real;
begin
   u0 := (4 * C_WHITE_X) / (C_WHITE_X + (C_WHITE_Y * 15) + (3 * C_WHITE_Z));
   v0 := (9 * C_WHITE_Y) / (C_WHITE_X + (C_WHITE_Y * 15) + (3 * C_WHITE_Z));
   // First we find out _y.
   if _l > C_CIE_KAPPA_EPSILON then
   begin
      _y := Power((_l + 16)/116, 3);
   end
   else
   begin
      _y := _l / C_CIE_KAPPA;
   end;
   // Now we find some other variables required for _x and _z.
   a := (((52 * _l) / (_u + (13 * _l * u0))) - 1) / 3;
   b := _y * (-5);
   c := -1/3;
   d := _y * (((39 * _l) / (_v + (13 * _l * v0))) - 5);
   // Then we find _x to find _z.
   _x := (d - b) / (a - c);
   _z := (_x * a) + b;
end;

procedure TColourUtils.LUVtoRGB(const _l, _u, _v: real; var _r, _g, _b: byte);
var
   x, y, z: real;
begin
   LUVtoXYZ(_l, _u, _v, x, y, z);
   XYZtoRGB(x, y, z, _r, _g, _b);
end;

procedure TColourUtils.LUVtoYIQ(const _l, _u, _v: real; var _y, _i, _q: real);
var
   x, y, z: real;
begin
   LUVtoXYZ(_l, _u, _v, x, y, z);
   XYZtoYIQ(x, y, z, _y, _i, _q);
end;

procedure TColourUtils.LUVtoLAB(const _l, _u, _v: real; var __l, __a, __b: real);
var
   x, y, z: real;
begin
   LUVtoXYZ(_l, _u, _v, x, y, z);
   XYZtoLAB(x, y, z, __l, __a, __b);
end;

procedure TColourUtils.LUVtoLCHab(const _l, _u, _v: real; var __l, __c, __h: real);
var
   x, y, z: real;
begin
   LUVtoXYZ(_l, _u, _v, x, y, z);
   XYZtoLCHab(x, y, z, __l, __c, __h);
end;

procedure TColourUtils.LUVtoLCHuv(const _l, _u, _v: real; var __l, __c, __h: real);
begin
   __l := _l;
   __c := sqrt((_u * _u) + (_v * _v));
   if _u <> 0 then
   begin
      __h := ArcTan2(_v, _u);
   end
   else
   begin
      if _v > 0 then
      begin
         __h := pi;
      end
      else
      begin
         __h := -pi;
      end;
   end;
end;

procedure TColourUtils.LCHuvtoXYZ(const _l, _c, _h: real; var _x, _y, _z: real);
var
   l, u, v: real;
begin
   LCHuvtoLUV(_l, _c, _h, l, u, v);
   LUVtoXYZ(l, u, v, _x, _y, _z);
end;

procedure TColourUtils.LCHuvtoRGB(const _l, _c, _h: real; var _r, _g, _b: byte);
var
   l, u, v: real;
begin
   LCHuvtoLUV(_l, _c, _h, l, u, v);
   LUVtoRGB(l, u, v, _r, _g, _b);
end;

procedure TColourUtils.LCHuvtoYIQ(const _l, _c, _h: real; var _y, _i, _q: real);
var
   l, u, v: real;
begin
   LCHuvtoLUV(_l, _c, _h, l, u, v);
   LUVtoYIQ(l, u, v, _y, _i, _q);
end;

procedure TColourUtils.LCHuvtoLAB(const _l, _c, _h: real; var __l, __a, __b: real);
var
   l, u, v: real;
begin
   LCHuvtoLUV(_l, _c, _h, l, u, v);
   LUVtoLAB(l, u, v, __l, __a, __b);
end;

procedure TColourUtils.LCHuvtoLCHab(const _l, _c, _h: real; var __l, __c, __h: real);
var
   l, u, v: real;
begin
   LCHuvtoLUV(_l, _c, _h, l, u, v);
   LUVtoLCHab(l, u, v, __l, __c, __h);
end;

procedure TColourUtils.LCHuvtoLUV(const _l, _c, _h: real; var __l, __u, __v: real);
begin
   __l := _l;
   __u := _c * cos(_h);
   __v := _c * sin(_h);
end;

end.
