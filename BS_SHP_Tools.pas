unit BS_SHP_Tools;

interface

uses Windows, Graphics, SHP_Image, SHP_File, Math, Palette, Colour_list, SHP_Colour_Bank,
   SHP_Engine_CCMs;

// Functions

// Line
function getgradient(last, First: TPoint2D): single;
procedure drawstraightline_temp(var tempview: TTempview;
   var TempView_no: integer; var last, First: TPoint2D);

// Flood And Fill
procedure FloodFillTool(var SHP: TSHP; Frame, Xpos, Ypos: integer; Colour: byte);

// Rectangle
procedure Rectangle(var Tempview: TTempview; var TempView_no: integer;
   Xpos, Ypos, Xpos2, Ypos2: integer; Fill: boolean);
procedure Rectangle_dotted(const SHP: TSHP; var TempView: TTempView;
   var TempView_no: integer; const SHPPalette: TPalette; Frame: word;
   Xpos, Ypos, Xpos2, Ypos2: integer);

// Elipse
procedure Elipse(var Tempview: TTempview; var TempView_no: integer;
   Xpos, Ypos, Xpos2, Ypos2: integer; Fill: boolean);

// Brush
procedure BrushTool(var SHP: TSHP; var TempView: TTempView;
   var TempView_no: integer; Xc, Yc, BrushMode, Colour: integer);

// DarkenLighten
procedure BrushToolDarkenLighten(var SHP: TSHP; Frame: word; Xc, Yc: integer;
   BrushMode: integer);
function darkenlightenv(Darken: boolean; Current_Value, Value: byte): byte;

// Damager
procedure Crash(const SHP: TSHP; var Palette: TPalette; var Tempview: TTempview;
   var TempView_no: integer; Xpos, Ypos: integer; const Frame: integer;
   const Alg: integer);


// Etc...
function InImageBounds(x, y: integer; const SHP: TSHP): boolean;
function OpositeColour(color: TColor): tcolor;


implementation

uses FormMain;

function getgradient(last, First: TPoint2D): single;
begin
   if (First.X = last.X) or (First.Y = last.Y) then
      Result := 0
   else
      Result := (First.Y - last.Y) / (First.X - last.X);
end;


procedure drawstraightline_temp(var tempview: Ttempview;
   var TempView_no: integer; var last, First: TPoint2D);
var
   x, y: integer;
   gradient, c: single;
begin
   // Straight Line Equation : Y=MX+C

   //memo1.lines.add('First Click:');
   //memo1.lines.add('X:' +inttostr(first.X)+' Y:' +inttostr(first.Y)+' Z:' +inttostr(first.Z));
   //memo1.lines.add('Last Click:');
   //memo1.lines.add('X:' +inttostr(last.X)+' Y:' +inttostr(last.Y)+' Z:' +inttostr(last.Z));

   gradient := getgradient(last, First);

   c := last.Y - (last.X * gradient);

   //memo1.lines.add(#13'Starting X:'+inttostr(first.X) + ' Starting Y:'+inttostr(first.Y));
   //memo1.lines.add('Ending X:'+inttostr(last.X) + ' Ending Y:'+inttostr(last.Y));

   //memo1.lines.add(#13'Gradient:'+floattostr(gradient));
   //memo1.lines.add('C:'+floattostr(c));

   //memo1.lines.add(#13'Using X constantly changing by 1 to get Y:');

   //showmessage(inttostr(gradient));

   TempView_no := 0;
   setlength(tempview, 0);

   if (gradient = 0) and (First.X = last.X) then
      for y := min(First.Y, last.y) to max(First.Y, last.y) do
      begin
         TempView_no := TempView_no + 1;
         setlength(tempview, TempView_no + 1);

         tempview[TempView_no].X := First.X;
         tempview[TempView_no].Y := y;

      end
   else
   if (gradient = 0) and (First.Y = last.Y) then
      for x := min(First.x, last.x) to max(First.x, last.x) do
      begin
         TempView_no := TempView_no + 1;
         setlength(tempview, TempView_no + 1);

         tempview[TempView_no].X := x;
         tempview[TempView_no].Y := First.Y;

      end
   else
   begin

      for x := min(First.X, last.X) to max(First.X, last.X) do
      begin
         //memo1.lines.add('Y:' +inttostr(round((gradient*x)+c)) + ' X:' + inttostr(x));
         TempView_no := TempView_no + 1;
         setlength(tempview, TempView_no + 1);

         tempview[TempView_no].X := x;
         tempview[TempView_no].Y := round((gradient * x) + c);

      end;

      //memo1.lines.add(#13'Using Y constantly changing by 1 to get X:');

      for y := min(First.Y, last.Y) to max(First.Y, last.Y) do
      begin
         //memo1.lines.add('Y:' +inttostr(y) + ' X:' + inttostr(round((y-c)/ gradient)));

         TempView_no := TempView_no + 1;
         setlength(tempview, TempView_no + 1);

         tempview[TempView_no].X := round((y - c) / gradient);
         tempview[TempView_no].Y := y;
      end;

   end;

end;

// File: Voxel.pas
// Original Procedure Name: procedure TVoxelSection.FloodFillTool(Xpos,Ypos,Zpos: Integer; v: TVoxelUnpacked; EditView: EVoxelViewOrient);
// Flood Fill Code Taken From Voxel Section Editor and adapted to this program

procedure FloodFillTool(var SHP: TSHP; Frame, Xpos, Ypos: integer; Colour: byte);
type
   FloodSet = (Left, Right, Up, Down);

   Flood2DPoint = record
      X, Y: integer;
   end;

   StackType = record
      Dir: set of FloodSet;
      p:   Flood2DPoint;
   end;

   function PointOK(var SHP: TSHP; l: Flood2DPoint): boolean;
   begin
      PointOK := False;
      if (l.X < 0) or (l.Y < 0) then
         Exit;
      if (l.X >= SHP.Header.Width) or (l.Y >= SHP.Header.Height) then
         Exit;
      PointOK := True;
   end;

var
   z1, z2:  byte;
   i, j, k: integer;         //this isn't 100% FloodFill, but function is very handy for user;
   Stack:   array of StackType; //this is the floodfill stack for my code
   SC, Sp:  integer; //stack counter and stack pointer
   po:      Flood2DPoint;
   Full:    set of FloodSet;
   Done:    array of array of boolean;
begin
   SetLength(Done, SHP.Header.Width, SHP.Header.Height);
   SetLength(Stack, SHP.Header.Width * SHP.Header.Height);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i := 0 to SHP.Header.Width - 1 do
      for j := 0 to SHP.Header.Height - 1 do
         Done[i, j] := False;

   z1 := SHP.Data[Frame].FrameImage[Xpos, Ypos];
   SHP.Data[Frame].FrameImage[Xpos, Ypos] := Colour;


   Full := [Left, Right, Up, Down];
   Sp   := 0;
   Stack[Sp].Dir := Full;
   Stack[Sp].p.X := Xpos;
   Stack[Sp].p.Y := Ypos;
   SC   := 1;
   while (SC > 0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
            //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Left];
         po := Stack[Sp].p;
         Dec(po.X);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP, po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X, po.Y] := Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Right]; //Don't go back
                  Stack[SC].p   := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
            //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Right];
         po := Stack[Sp].p;
         Inc(po.X);
         //now check this point - only if it's within range, check it.
         if PointOK(SHP, po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X, po.Y] := Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Left]; //Don't go back
                  Stack[SC].p   := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check left
            //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Up];
         po := Stack[Sp].p;
         Dec(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP, po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X, po.Y] := Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Down]; //Don't go back
                  Stack[SC].p   := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
            //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Down];
         po := Stack[Sp].p;
         Inc(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP, po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X, po.Y] := Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Up]; //Don't go back
                  Stack[SC].p   := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if (Stack[Sp].Dir = []) then
      begin
         Dec(Sp);
         Dec(SC);
         //decrease stack pointer and stack count
      end;
   end;
   SetLength(Stack, 0); // Free Up Memory
   SetLength(Done, 0);  // Free Up Memory
end;

// File: FormMain.pas
// Original Procedure Name: procedure TFrmMain.Rectangle(Xpos,Ypos,Zpos,Xpos2,Ypos2,Zpos2:Integer; Fill: Boolean);
// Flood Fill Code Taken From Voxel Section Editor and adapted to this program

procedure Rectangle(var Tempview: TTempview; var TempView_no: integer;
   Xpos, Ypos, Xpos2, Ypos2: integer; Fill: boolean);
var
   i, j: integer;
   Inside, Exact: integer;
begin

   tempview_no := 0;
   setlength(tempview, 0);

   for i := Min(Xpos, Xpos2) to Max(Xpos, Xpos2) do
   begin
      for j := Min(Ypos, Ypos2) to Max(Ypos, Ypos2) do
      begin
         Inside := 0;
         Exact  := 0;

         if (i > Min(Xpos, Xpos2)) and (i < Max(Xpos, Xpos2)) then
            Inc(Inside);
         if (j > Min(Ypos, Ypos2)) and (j < Max(Ypos, Ypos2)) then
            Inc(Inside);
         if (i = Min(Xpos, Xpos2)) or (i = Max(Xpos, Xpos2)) then
            Inc(Exact);
         if (j = Min(Ypos, Ypos2)) or (j = Max(Ypos, Ypos2)) then
            Inc(Exact);

         if Fill then
         begin
            if Inside + Exact = 2 then
            begin
               tempview_no := tempview_no + 1;
               setlength(tempview, tempview_no + 1);
               tempview[tempview_no].X := i;
               tempview[tempview_no].Y := j;
            end;
         end
         else
         begin
            if (Exact >= 1) and (Inside + Exact = 2) then
            begin
               tempview_no := tempview_no + 1;
               setlength(tempview, tempview_no + 1);
               tempview[tempview_no].X := i;
               tempview[tempview_no].Y := j;
            end;
         end;
      end;
   end;
end;

procedure Elipse(var Tempview: TTempview; var TempView_no: integer;
   Xpos, Ypos, Xpos2, Ypos2: integer; Fill: boolean);
var
   i, j, k, a, b, c, d, last: smallint;
begin

   tempview_no := 0;
   setlength(tempview, 0);
   if abs(Xpos - Xpos2) >= abs(Ypos - Ypos2) then
   begin
      a := sqr(abs((Xpos - Xpos2) div 2));
      b := sqr(abs((Ypos - Ypos2) div 2));
      c := (Ypos + Ypos2) div 2;
      d := (Xpos + Xpos2) div 2;
      if (a >= 1) and not Fill then
      begin
         last := round(sqrt((b *
            (a - ((d - Min(Xpos, Xpos2)) * (d - Min(Xpos, Xpos2))))) div a));
         for i := (d - Min(Xpos, Xpos2)) downto 0 do
         begin
            j := round(sqrt((b * (a - (i * i))) div a));
            if abs(j - last) > 1 then
            begin
               for k := abs(j - last) downto 0 do
               begin
                  tempview_no := tempview_no + 1;
                  setlength(tempview, tempview_no + 4);
                  tempview[tempview_no].X := d + i;
                  tempview[tempview_no].Y := c + j - k;
                  tempview_no := tempview_no + 1;
                  tempview[tempview_no].X := d + i;
                  tempview[tempview_no].Y := c - j + k;
                  tempview_no := tempview_no + 1;
                  tempview[tempview_no].X := d - i;
                  tempview[tempview_no].Y := c + j - k;
                  tempview_no := tempview_no + 1;
                  tempview[tempview_no].X := d - i;
                  tempview[tempview_no].Y := c - j + k;
               end;
            end
            else
            begin
               tempview_no := tempview_no + 1;
               setlength(tempview, tempview_no + 4);
               tempview[tempview_no].X := d + i;
               tempview[tempview_no].Y := c + j;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := d + i;
               tempview[tempview_no].Y := c - j;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := d - i;
               tempview[tempview_no].Y := c + j;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := d - i;
               tempview[tempview_no].Y := c - j;
            end;
            last := j;
         end;
      end
      else if (a >= 1) and Fill then
      begin
         //        last := round(sqrt((b * (a - ((d - Min(Xpos,Xpos2)) * (d - Min(Xpos,Xpos2))))) div a));
         for i := (d - Min(Xpos, Xpos2)) downto 0 do
         begin
            j := round(sqrt((b * (a - (i * i))) div a));
            for k := (c - j) to (c + j) do
            begin
               tempview_no := tempview_no + 1;
               setlength(tempview, tempview_no + 2);
               tempview[tempview_no].X := d + i;
               tempview[tempview_no].Y := k;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := d - i;
               tempview[tempview_no].Y := k;
            end;
         end;
      end
      else
      begin
         tempview_no := tempview_no + 1;
         setlength(tempview, tempview_no + 1);
         tempview[tempview_no].X := Xpos;
         tempview[tempview_no].Y := Ypos;
      end;
   end
   else
   begin
      a := sqr(abs((Ypos - Ypos2) div 2));
      b := sqr(abs((Xpos - Xpos2) div 2));
      c := (Xpos + Xpos2) div 2;
      d := (Ypos + Ypos2) div 2;
      if (a >= 1) and not Fill then
      begin
         last := round(sqrt((b *
            (a - ((d - Min(Ypos, Ypos2)) * (d - Min(Ypos, Ypos2))))) div a));
         for i := (d - Min(Ypos, Ypos2)) downto 0 do
         begin
            j := round(sqrt((b * (a - (i * i))) div a));
            if abs(j - last) > 1 then
            begin
               for k := abs(j - last) downto 0 do
               begin
                  tempview_no := tempview_no + 1;
                  setlength(tempview, tempview_no + 4);
                  tempview[tempview_no].X := c + j - k;
                  tempview[tempview_no].Y := d + i;
                  tempview_no := tempview_no + 1;
                  tempview[tempview_no].X := c - j + k;
                  tempview[tempview_no].Y := d + i;
                  tempview_no := tempview_no + 1;
                  tempview[tempview_no].X := c + j - k;
                  tempview[tempview_no].Y := d - i;
                  tempview_no := tempview_no + 1;
                  tempview[tempview_no].X := c - j + k;
                  tempview[tempview_no].Y := d - i;
               end;
            end
            else
            begin
               tempview_no := tempview_no + 1;
               setlength(tempview, tempview_no + 4);
               tempview[tempview_no].X := c + j;
               tempview[tempview_no].Y := d + i;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := c - j;
               tempview[tempview_no].Y := d + i;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := c + j;
               tempview[tempview_no].Y := d - i;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := c - j;
               tempview[tempview_no].Y := d - i;
            end;
            last := j;
         end;
      end
      else if (a >= 1) and Fill then
      begin
         //        last := round(sqrt((b * (a - ((d - Min(Ypos,Ypos2)) * (d - Min(Ypos,Ypos2))))) div a));
         for i := (d - Min(Ypos, Ypos2)) downto 0 do
         begin
            j := round(sqrt((b * (a - (i * i))) div a));
            for k := (c - j) to (c + j) do
            begin
               tempview_no := tempview_no + 1;
               setlength(tempview, tempview_no + 2);
               tempview[tempview_no].X := k;
               tempview[tempview_no].Y := d + i;
               tempview_no := tempview_no + 1;
               tempview[tempview_no].X := k;
               tempview[tempview_no].Y := d - i;
            end;
         end;
      end
      else
      begin
         tempview_no := tempview_no + 1;
         setlength(tempview, tempview_no + 1);
         tempview[tempview_no].X := Xpos;
         tempview[tempview_no].Y := Ypos;
      end;
   end;
end;

procedure Crash(const SHP: TSHP; var Palette: TPalette; var Tempview: TTempview;
   var TempView_no: integer; Xpos, Ypos: integer; const Frame: integer;
   const Alg: integer);
var
   List, Last: listed_colour;
   Start:      colour_element;
begin
   tempview_no := 0;
   setlength(tempview, 0);

   // Set List and Last
   GenerateColourList(Palette, List, Last, Palette[0], True, True, True);

   // Prepare Bank
   PrepareBank(Start, List, Last);

   // Now, grab the colours -- First row (XPos-1)
   if XPos > 0 then
   begin
      if (YPos > 0) and (SHP.Data[Frame].FrameImage[XPos - 1, YPos - 1] <> 0) then
      begin
         Tempview[Tempview_no].X      := XPos - 1;
         TempView[Tempview_no].Y      := YPos - 1;
         TempView[Tempview_no].colour :=
            Palette[LoadPixel(List, Last, alg, RGB(
            GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos - 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos - 1]) + 4) div
            3), GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos - 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos - 1]) + 4) div
            3), GetBValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos - 1]) -
            ((GetBValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos - 1]) + 4) div 3)))];
         TempView[Tempview_no].colour_used := True;
      end;
      if (SHP.Data[Frame].FrameImage[XPos - 1, YPos] <> 0) then
      begin
         Tempview[Tempview_no].X      := XPos - 1;
         TempView[Tempview_no].Y      := YPos;
         TempView[Tempview_no].colour :=
            Palette[LoadPixel(List, Last, alg, RGB(GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos]) -
            (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos]) + 4) div 3)),
            GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos]) -
            (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos]) + 4) div 3)),
            GetBValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos]) -
            (2 * ((GetBValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos]) + 4) div 3))))];
         TempView[Tempview_no].colour_used := True;
      end;
      if (YPos < (SHP.Header.Height - 1)) and
         (SHP.Data[Frame].FrameImage[XPos - 1, YPos + 1] <> 0) then
      begin
         Tempview[Tempview_no].X      := XPos - 1;
         TempView[Tempview_no].Y      := YPos + 1;
         TempView[Tempview_no].colour :=
            Palette[LoadPixel(List, Last, alg, RGB(
            GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos + 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos + 1]) + 4) div
            3), GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos + 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos + 1]) + 4) div
            3), GetBValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos + 1]) -
            ((GetBValue(SHP.Data[Frame].FrameImage[XPos - 1, YPos + 1]) + 4) div 3)))];
         TempView[Tempview_no].colour_used := True;
      end;
   end;

   // middle row (XPos)
   if (YPos > 0) and (SHP.Data[Frame].FrameImage[XPos, YPos - 1] <> 0) then
   begin
      Tempview[Tempview_no].X      := XPos;
      TempView[Tempview_no].Y      := YPos - 1;
      TempView[Tempview_no].colour :=
         Palette[LoadPixel(List, Last, alg, RGB(GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos - 1]) -
         (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos - 1]) + 4) div 3)),
         GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos - 1]) -
         (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos - 1]) + 4) div 3)),
         GetBValue(SHP.Data[Frame].FrameImage[XPos, YPos - 1]) -
         (2 * ((GetBValue(SHP.Data[Frame].FrameImage[XPos, YPos - 1]) + 4) div 3))))];
      TempView[Tempview_no].colour_used := True;
   end;
   if (SHP.Data[Frame].FrameImage[XPos, YPos] <> 0) then
   begin
      Tempview[Tempview_no].X      := XPos;
      TempView[Tempview_no].Y      := YPos;
      TempView[Tempview_no].colour := Palette[LoadPixel(List, Last, alg, RGB(4, 4, 4))];
      TempView[Tempview_no].colour_used := True;
   end;
   if (YPos < (SHP.Header.Height - 1)) and
      (SHP.Data[Frame].FrameImage[XPos, YPos + 1] <> 0) then
   begin
      Tempview[Tempview_no].X      := XPos;
      TempView[Tempview_no].Y      := YPos + 1;
      TempView[Tempview_no].colour :=
         Palette[LoadPixel(List, Last, alg, RGB(GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos + 1]) -
         (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos + 1]) + 4) div 3)),
         GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos + 1]) -
         (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos, YPos + 1]) + 4) div 3)),
         GetBValue(SHP.Data[Frame].FrameImage[XPos, YPos + 1]) -
         (2 * ((GetBValue(SHP.Data[Frame].FrameImage[XPos, YPos + 1]) + 4) div 3))))];
      TempView[Tempview_no].colour_used := True;
   end;

   // final row (XPos + 1)
   if XPos < (SHP.Header.Width - 1) then
   begin
      if (YPos > 0) and (SHP.Data[Frame].FrameImage[XPos + 1, YPos - 1] <> 0) then
      begin
         Tempview[Tempview_no].X      := XPos + 1;
         TempView[Tempview_no].Y      := YPos - 1;
         TempView[Tempview_no].colour :=
            Palette[LoadPixel(List, Last, alg, RGB(
            GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos - 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos - 1]) + 4) div
            3), GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos - 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos - 1]) + 4) div
            3), GetBValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos - 1]) -
            ((GetBValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos - 1]) + 4) div 3)))];
         TempView[Tempview_no].colour_used := True;
      end;
      if (SHP.Data[Frame].FrameImage[XPos + 1, YPos] <> 0) then
      begin
         Tempview[Tempview_no].X      := XPos + 1;
         TempView[Tempview_no].Y      := YPos;
         TempView[Tempview_no].colour :=
            Palette[LoadPixel(List, Last, alg, RGB(GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos]) -
            (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos]) + 4) div 3)),
            GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos]) -
            (2 * ((GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos]) + 4) div 3)),
            GetBValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos]) -
            (2 * ((GetBValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos]) + 4) div 3))))];
         TempView[Tempview_no].colour_used := True;
      end;
      if (YPos < (SHP.Header.Height - 1)) and
         (SHP.Data[Frame].FrameImage[XPos + 1, YPos + 1] <> 0) then
      begin
         Tempview[Tempview_no].X      := XPos + 1;
         TempView[Tempview_no].Y      := YPos + 1;
         TempView[Tempview_no].colour :=
            Palette[LoadPixel(List, Last, alg, RGB(
            GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos + 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos + 1]) + 4) div
            3), GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos + 1]) -
            ((GetRValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos + 1]) + 4) div
            3), GetBValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos + 1]) -
            ((GetBValue(SHP.Data[Frame].FrameImage[XPos + 1, YPos + 1]) + 4) div 3)))];
         TempView[Tempview_no].colour_used := True;
      end;
   end;

   // Remove the trash:
   ClearColourList(List, Last);
   ClearBank(Start);
end;

function OpositeColour(color: TColor): tcolor;
var
   r, rr, g, b: byte;
begin

   r := 255 - GetRValue(color);
   g := 255 - GetGValue(color);
   b := 255 - GetBValue(color);

   Result := RGB(r, g, b);
end;

// File: FormMain.pas
// Original Procedure Name: procedure TFrmMain.BrushToolDarkenLighten(Xc,Yc,Zc: Integer; V: TVoxelUnpacked; BrushMode: Integer; BrushView: EVoxelViewOrient);
// BrushToolDarkenLighten Code Taken From Voxel Section Editor and adapted to this program

// BrushTool modifyed by Stucuk from TVoxelSection.BrushToolDarkenLighten
procedure BrushTool(var SHP: TSHP; var TempView: TTempView;
   var TempView_no: integer; Xc, Yc, BrushMode, Colour: integer);
var
   Shape: array[-5..5, -5..5] of 0..1;
   i, j, r1, r2: integer;
begin
   Randomize;
   //SetLength(TempView,0);
   //TempView_no := 0;

   for i := -5 to 5 do
      for j := -5 to 5 do
         Shape[i, j] := 0;
   Shape[0, 0] := 1;
   if BrushMode >= 1 then
   begin
      Shape[0, 1]  := 1;
      Shape[0, -1] := 1;
      Shape[1, 0]  := 1;
      Shape[-1, 0] := 1;
   end;
   if BrushMode >= 2 then
   begin
      Shape[1, 1]   := 1;
      Shape[1, -1]  := 1;
      Shape[-1, -1] := 1;
      Shape[-1, 1]  := 1;
   end;
   if BrushMode >= 3 then
   begin
      Shape[0, 2]  := 1;
      Shape[0, -2] := 1;
      Shape[2, 0]  := 1;
      Shape[-2, 0] := 1;
   end;

   if BrushMode = 4 then
   begin
      for i := -5 to 5 do
         for j := -5 to 5 do
            Shape[i, j] := 0;

      for i := 1 to 4 do
      begin
         r1 := random(7) - 3;
         r2 := random(7) - 3;
         Shape[r1, r2] := 1;
      end;
   end;
   //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   for i := -5 to 5 do
   begin
      for j := -5 to 5 do
      begin
         if Shape[i, j] = 1 then
         begin
            Inc(TempView_no);
            SetLength(TempView, TempView_no + 1);
            TempView[TempView_no].X := Max(Min(Xc + i, SHP.Header.Width - 1), 0);
            TempView[TempView_no].Y := Max(Min(Yc + j, SHP.Header.Height - 1), 0);
            // SHP.Data[Current_Frame.Value].FrameImage[,] := Colour;
         end;
      end;
   end;
end;

function InImageBounds(x, y: integer; const SHP: TSHP): boolean;
begin
   Result := True; // Assume its in the image

   // Check minimum
   if (x < 0) or (y < 0) then
      Result := False;

   // Check Max
   if (x > SHP.Header.Width - 1) or (y > SHP.Header.Height - 1) then
      Result := False;

end;

// File: FormMain.pas
// Original Procedure Name: procedure TFrmMain.Rectangle(Xpos,Ypos,Zpos,Xpos2,Ypos2,Zpos2:Integer; Fill: Boolean);

procedure Rectangle_dotted(const SHP: TSHP; var TempView: TTempView;
   var TempView_no: integer; const SHPPalette: TPalette; Frame: word;
   Xpos, Ypos, Xpos2, Ypos2: integer);
var
   x, y, c: integer;
begin

   tempview_no := 0;
   setlength(tempview, 0);

   c := 0;
   for x := Max(Min(Xpos, Xpos2), 0) to Min(SHP.Header.Width - 1, Max(Xpos, Xpos2)) do
   begin
      Inc(c);
      if (c < 4) and (InImageBounds(x, Min(Ypos, Ypos2), SHP)) then
      begin
         tempview_no := tempview_no + 1;
         setlength(tempview, tempview_no + 1);
         tempview[tempview_no].X      := x;
         tempview[tempview_no].Y      := Min(Ypos, Ypos2);
         tempview[tempview_no].colour_used := True;
         tempview[tempview_no].colour :=
            OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[x, Min(Ypos, Ypos2)]]);

      end
      else
         c := 0;
   end;

   c := 0;
   for x := Max(Min(Xpos, Xpos2), 0) to Min(SHP.Header.Width - 1, Max(Xpos, Xpos2)) do
   begin
      Inc(c);
      if (c < 4) and (InImageBounds(x, Max(Ypos, Ypos2), SHP)) then
      begin
         tempview_no := tempview_no + 1;
         setlength(tempview, tempview_no + 1);
         tempview[tempview_no].X      := x;
         tempview[tempview_no].Y      := Max(Ypos, Ypos2);
         tempview[tempview_no].colour_used := True;
         tempview[tempview_no].colour :=
            OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[x, Max(Ypos, Ypos2)]]);
      end
      else
         c := 0;
   end;

   c := 0;
   for y := Max(Min(Ypos, Ypos2), 0) to Min(SHP.Header.Height - 1, Max(Ypos, Ypos2)) do
   begin
      Inc(c);
      if (c < 4) and (InImageBounds(Min(Xpos, Xpos2), y, SHP)) then
      begin
         tempview_no := tempview_no + 1;
         setlength(tempview, tempview_no + 1);
         tempview[tempview_no].X      := Min(Xpos, Xpos2);
         tempview[tempview_no].Y      := y;
         tempview[tempview_no].colour_used := True;
         tempview[tempview_no].colour :=
            OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[Min(Xpos, Xpos2), y]]);
      end
      else
         c := 0;
   end;

   c := 0;
   for y := Max(Min(Ypos, Ypos2), 0) to Min(SHP.Header.Height - 1, Max(Ypos, Ypos2)) do
   begin
      Inc(c);
      if (c < 4) and (InImageBounds(Max(Xpos, Xpos2), y, SHP)) then
      begin
         tempview_no := tempview_no + 1;
         setlength(tempview, tempview_no + 1);
         tempview[tempview_no].X      := Max(Xpos, Xpos2);
         tempview[tempview_no].Y      := y;
         tempview[tempview_no].colour_used := True;
         tempview[tempview_no].colour :=
            OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[Max(Xpos, Xpos2), y]]);
      end
      else
         c := 0;
   end;
end;

function darkenlightenv(Darken: boolean; Current_Value, Value: byte): byte;
var
   temp: word;
begin

   if darken then
      temp := Current_Value - Value
   else
      temp := Current_Value + Value;

   if temp < 1 then
      temp := temp + 255;

   if temp > 255 then
      temp := temp - 255;

   Result := temp;

end;

// File: FormMain.pas
// Original Procedure Name: procedure TFrmMain.BrushToolDarkenLighten(Xc,Yc,Zc: Integer; V: TVoxelUnpacked; BrushMode: Integer; BrushView: EVoxelViewOrient);
// BrushToolDarkenLighten Code Taken From Voxel Section Editor and adapted to this program

// BrushToolDarkenLighten modifyed by Stucuk from TVoxelSection.BrushTool
procedure BrushToolDarkenLighten(var SHP: TSHP; Frame: word; Xc, Yc: integer;
   BrushMode: integer);
var
   Shape: array[-5..5, -5..5] of 0..1;
   i, j, r1, r2: integer;
   t:     byte;
begin
   Randomize;
   for i := -5 to 5 do
      for j := -5 to 5 do
         Shape[i, j] := 0;
   Shape[0, 0] := 1;
   if BrushMode >= 1 then
   begin
      Shape[0, 1]  := 1;
      Shape[0, -1] := 1;
      Shape[1, 0]  := 1;
      Shape[-1, 0] := 1;
   end;
   if BrushMode >= 2 then
   begin
      Shape[1, 1]   := 1;
      Shape[1, -1]  := 1;
      Shape[-1, -1] := 1;
      Shape[-1, 1]  := 1;
   end;
   if BrushMode >= 3 then
   begin
      Shape[0, 2]  := 1;
      Shape[0, -2] := 1;
      Shape[2, 0]  := 1;
      Shape[-2, 0] := 1;
   end;

   if BrushMode = 4 then
   begin
      for i := -5 to 5 do
         for j := -5 to 5 do
            Shape[i, j] := 0;

      for i := 1 to 4 do
      begin
         r1 := random(7) - 3;
         r2 := random(7) - 3;
         Shape[r1, r2] := 1;
      end;
   end;
   //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   for i := -5 to 5 do
   begin
      for j := -5 to 5 do
      begin
         if Shape[i, j] = 1 then
         begin
            t := SHP.Data[Frame].FrameImage[Max(Min(Xc + i, SHP.Header.Width - 1), 0),
               Max(Min(Yc + j, SHP.Header.Height - 1), 0)];
            SHP.Data[Frame].FrameImage[Max(Min(Xc + i, SHP.Header.Width - 1), 0), Max(
               Min(Yc + j, SHP.Header.Height - 1), 0)] :=
               darkenlightenv(FrmMain.DarkenLighten_B, t, FrmMain.DarkenLighten_N);
         end;
      end;
   end;
end;

end.
