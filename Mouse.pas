 // MOUSE.PAS
 // By Banshee & Stucuk

unit Mouse;

interface

uses
   Windows, SysUtils, Forms;

const
   MouseBrush   = 1201;
   MouseLine    = 1203;
   MouseDropper = 1204;
   MouseFill    = 1205;
   MouseDraw    = 1206;
   MouseMagnify = 1207;
   MouseSpray   = 8029;
   MouseMoveC   = 1033; // Named MouseMoveC cos of other things named MouseMove

function LoadMouseCursors: boolean;
function LoadMouseCursor(Number: integer): integer;

implementation

uses FormMain;

function LoadMouseCursors: boolean;
var
   temp: integer;
begin
   Result := True;
   temp   := 0;
   temp   := temp + LoadMouseCursor(MouseBrush);
   temp   := temp + LoadMouseCursor(MouseLine);
   temp   := temp + LoadMouseCursor(MouseDropper);
   temp   := temp + LoadMouseCursor(MouseFill);
   temp   := temp + LoadMouseCursor(MouseDraw);
   temp   := temp + LoadMouseCursor(MouseMagnify);
   temp   := temp + LoadMouseCursor(MouseSpray);
   temp   := temp + LoadMouseCursor(MouseMoveC);

   if temp < 0 then
      Result := False;
end;

function LoadMouseCursor(Number: integer): integer;
var
   filename: PChar;
begin
   Result := 0;
   filename := PChar(ExtractFileDir(ParamStr(0)) + '\Cursors\' + IntToStr(Number) + '.cur');
   if not fileexists(filename) then
   begin
      FrmMain.RunInstall;
   end
   else
      Screen.Cursors[Number] := LoadCursorFromFile(filename);
end;

end.
