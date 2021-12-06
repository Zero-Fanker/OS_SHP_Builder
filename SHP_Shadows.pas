unit SHP_Shadows;

interface

uses
   SHP_File;

function IsShadowGeneric(const _SHP: TSHP; _NumFrames, _Frame: integer): boolean;
function IsShadow(const _SHP: TSHP; _Frame: integer): boolean;
function IsShadowAddFrames(const _SHP: TSHP; _Frame: integer): boolean;
function GetOposite(var _SHP: TSHP; const _Frame: integer): integer;
function GetOpositeAddFrames(var _SHP: TSHP; const _Frame: integer): integer;
function GetShadowOposite(const _SHP: TSHP; _Frame: integer): integer;
function GetShadowOpositeAddFrames(const _SHP: TSHP; _Frame: integer): integer;
function GetShadowFromOposite(const _SHP: TSHP; _Frame: integer): integer;
function GetShadowFromOpositeAddFrames(const _SHP: TSHP; _Frame: integer): integer;
function HasShadows(const _SHP: TSHP): boolean;

implementation

function IsShadowGeneric(const _SHP: TSHP; _NumFrames, _Frame: integer): boolean;
var
   shadow_start: integer;
begin
   Result := False;
   // Shadows start half way through the file +1 frame
   shadow_start := (_NumFrames div 2) + 1;

   // Check to see if current frame is above or equal to the shadow start value
   if _Frame >= shadow_start then
      Result := True;

   if (_SHP.SHPType = stCameo) or (_SHP.SHPGame = sgTD) or (_SHP.SHPGame = sgRA1) then
      // Check if it is not a unit/building/animation.
      Result := False; // Only Units/buildings/animations have shadows
end;

function IsShadow(const _SHP: TSHP; _Frame: integer): boolean;
begin
   Result := IsShadowGeneric(_SHP, _SHP.Header.NumImages, _Frame);
end;

function IsShadowAddFrames(const _SHP: TSHP; _Frame: integer): boolean;
begin
   Result := IsShadowGeneric(_SHP, _SHP.Header.NumImages + 2, _Frame);
end;

function GetShadowOposite(const _SHP: TSHP; _Frame: integer): integer;
var
   shadow_start: integer;
begin
   // Shadows start half way through the file
   shadow_start := (_SHP.Header.NumImages div 2);

   if not IsShadow(_SHP, _Frame) then
      Result := 0 // Error;
   else
      Result := _Frame - shadow_start;
end;

function GetShadowOpositeAddFrames(const _SHP: TSHP; _Frame: integer): integer;
var
   shadow_start: integer;
begin
   // Shadows start half way through the file
   shadow_start := (_SHP.Header.NumImages div 2) + 1;

   if not IsShadowAddFrames(_SHP, _Frame) then
      Result := 0 // Error;
   else
      Result := _Frame - shadow_start;
end;

function GetShadowFromOposite(const _SHP: TSHP; _Frame: integer): integer;
var
   shadow_start: integer;
begin
   // Shadows start half way through the file
   shadow_start := (_SHP.Header.NumImages div 2);

   Result := _Frame + shadow_start;
end;

function GetShadowFromOpositeAddFrames(const _SHP: TSHP; _Frame: integer): integer;
var
   shadow_start: integer;
begin
   // Shadows start half way through the file
   shadow_start := (_SHP.Header.NumImages div 2) + 1;

   Result := _Frame + shadow_start;
end;

function GetOposite(var _SHP: TSHP; const _Frame: integer): integer;
begin
   if IsShadow(_SHP, _Frame) then
      Result := GetShadowOposite(_SHP, _Frame)
   else
      Result := GetShadowFromOposite(_SHP, _Frame);
end;

function GetOpositeAddFrames(var _SHP: TSHP; const _Frame: integer): integer;
begin
   if IsShadowAddFrames(_SHP, _Frame) then
      Result := GetShadowOpositeAddFrames(_SHP, _Frame)
   else
      Result := GetShadowFromOpositeAddFrames(_SHP, _Frame);
end;

function HasShadows(const _SHP: TSHP): boolean;
begin
   Result := True; // Assume True
   if (_SHP.SHPType = stcameo) or (_SHP.SHPType = sttem) or (_SHP.SHPType = stsno) or
      (_SHP.SHPType = stAnimation) then
      Result := False;
   if (_SHP.SHPGame = sgTD) or (_SHP.SHPGame = sgRA1) then
      Result := False;
end;

end.
