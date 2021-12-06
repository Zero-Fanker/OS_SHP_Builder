unit FormSHPImage;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ExtCtrls, ComCtrls, StdCtrls, Spin, SHP_file, SHP_Shadows,
   SHP_Image, Palette, Undo_Redo, Mouse, math, XPMan;

type
   TFrmSHPImage = class(TForm)
      PaintAreaPanel: TPanel;
      Image1: TImage;
      ScrollBox1: TScrollBox;
      XPManifest: TXPManifest;
      procedure ResizePaintArea(var Image1 : TImage; var PaintAreaPannel: TPanel);
      procedure RefreshImage1;
//    procedure Current_FrameChange(Sender: TObject);
      procedure SetShadowColour(Col: Integer);
      procedure SetActiveColour(Col: Integer);
      procedure SetBackGroundColour(Col: Integer);
      procedure SetBackGround(Value: boolean);
      procedure UpdateSHPTypeFromGame;
      procedure UpdateSHPTypeMenu;
      procedure WriteSHPType;
//    procedure Zoom_FactorChange(Sender: TObject);
//    procedure lbl_total_framesDblClick(Sender: TObject);
      procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure SetShadowMode(Value : boolean);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure FormShow(Sender: TObject);
      procedure FormActivate(Sender: TObject);
      procedure FormResize(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure AutoGetCursor;
      procedure WorkOutImageClick(var SHP: TSHP; var X,Y : integer; var OutOfRange : boolean; zoom:byte);
    //    procedure FormResize(Sender: TObject);
   private
      { Private declarations }
      procedure DrawCenter;
      procedure DrawGrid;
   public
      { Public declarations }
      First,Last,LastPreview : TPoint2D;
      ActiveColour,ShadowColour,BackGroundColour : byte;
      DisableBackground: boolean; // 3.3: Background adition
      Zoom : byte;
      MaxZoom : byte;
      Frame : longword;
      ShadowMode : boolean;
      alg : byte;
      show_center : boolean;
      DefultCursor : integer;
      ID : word;
      Data : Pointer;
      Address : Pointer;
      SelectData : TSelectData;
      C : Boolean;
      ShowGrid : boolean;
      GridSize : byte;
   end;

implementation

uses FormMain, FormPreview, OS_SHP_Tools, SHP_DataMatrix, SHP_Engine;


{$R *.dfm}
procedure TFrmSHPImage.ResizePaintArea(var Image1 : TImage; var PaintAreaPannel: TPanel);
var
   SHPData : TSHPImageData;
   width, height : word;
begin
   if Data = nil then exit;
   SHPData := Data;

   // Cache basic values
   width := (SHPData^.SHP.header.Width * Zoom);
   height := (SHPData^.SHP.header.Height * Zoom);

   if WindowState = WSNormal then
   begin
      ClientWidth := Width + 4;
      ClientHeight := Height + 4;
   end;

   FormResize(nil);

   // Paintpanel is resized to the images width, image is on the panel, and panel is coloured the same colour as transparent
   // The result is less flicker, there is still some, but its greatly reduced. note: Double buffer fixed flickering
   PaintAreaPanel.Width := Width;
   PaintAreaPanel.Height := Height;

   // Set image width n height
   Image1.Picture.Bitmap.Width := width;
   Image1.Picture.Bitmap.Height := height;

   Image1.Width := Width;
   Image1.Height := Height;
end;

procedure TFrmSHPImage.DrawCenter;
var
   x,y: integer;
   SHPData : TSHPImageData;
begin
   SHPData := Data;
   for x := 0 to SHPData^.SHP.Header.Width -1 do
      for y := 0 to SHPData^.SHP.Header.Height-1 do
         if (x = (SHPData^.SHP.Header.Width-1) div 2) or (y = (SHPData^.SHP.Header.Height-1) div 2) then
         begin
            image1.Picture.Bitmap.Canvas.Brush.Color := OpositeColour(image1.Picture.Bitmap.Canvas.Pixels[(x*Zoom),(y*Zoom)]);
            image1.Picture.Bitmap.Canvas.FillRect(Rect((x*Zoom),(y*Zoom),(x*Zoom)+Zoom,(y*Zoom)+Zoom));
         end;
end;

procedure TFrmSHPImage.DrawGrid;
var
   x,y,x2,y2,c,xZ,yZ,xdiv2,r: integer;
   SHPData : TSHPImageData;
begin
   SHPData := Data;
   r:=-1;
   //first half of screen.
   for x:= (SHPData^.SHP.Header.Width shr 1) downto (-GridSize) do
   begin
      xdiv2 := x shr 1;
      y:= abs(xdiv2-(SHPData^.SHP.Header.Width shr 2))+((SHPData^.SHP.Header.Height) shr 1)-1;
      xZ:=(x-1)*Zoom;
      yZ:=(y-1)*Zoom;
      image1.Picture.Bitmap.Canvas.Brush.Color := OpositeColour(image1.Picture.Bitmap.Canvas.Pixels[xZ,yZ]);
      image1.Picture.Bitmap.Canvas.FillRect(Rect(xZ,yZ,xZ+Zoom,yZ+Zoom));
      inc(r);
      if (r mod GridSize=0) and (r>0) then
      begin
         r:=0;
         x2:=x;
         y2:=y;
         c:=y-xdiv2;
         while y2<SHPData^.SHP.Header.Height do
         begin
            y2:=(x2 shr 1)+c;
            xZ:=(x2-1)*Zoom;
            yZ:=(y2-1)*Zoom;
            image1.Picture.Bitmap.Canvas.Brush.Color := OpositeColour(image1.Picture.Bitmap.Canvas.Pixels[xZ,yZ]);
            image1.Picture.Bitmap.Canvas.FillRect(Rect(xZ,yZ,xZ+Zoom,yZ+Zoom));
            inc(x2);
         end;
      end;
   end;

   r:=-1;
   for x:= (SHPData^.SHP.Header.Width shr 1) to SHPData^.SHP.Header.Width + GridSize do
   begin
      y:=abs((x shr 1)-(SHPData^.SHP.Header.Width shr 2))+((SHPData^.SHP.Header.Height) shr 1)-1;
      image1.Picture.Bitmap.Canvas.Brush.Color := OpositeColour(image1.Picture.Bitmap.Canvas.Pixels[(x*Zoom),(y*Zoom)]);
      image1.Picture.Bitmap.Canvas.FillRect(Rect((x*Zoom),(y*Zoom),(x*Zoom)+Zoom,(y*Zoom)+Zoom));
      inc(r);
      if (r mod GridSize=0) and (r>0) then
      begin
         r:=0;
         x2:=x;
         y2:=y;
         c:=y+(x shr 1);
         while y2 < SHPData^.SHP.Header.Height do
         begin
            y2:= abs(-(x2 shr 1) + c);
            image1.Picture.Bitmap.Canvas.Brush.Color := OpositeColour(image1.Picture.Bitmap.Canvas.Pixels[(x2*Zoom),(y2*Zoom)]);
            image1.Picture.Bitmap.Canvas.FillRect(Rect((x2*Zoom),(y2*Zoom),(x2*Zoom)+Zoom,(y2*Zoom)+Zoom));
            dec(x2);
         end;
      end;
   end;
end;

procedure TFrmSHPImage.RefreshImage1;
var
   x:integer;
   IsItShadow : boolean;
   SHPData : TSHPImageData;
   Colour : TColor;
begin
   if Data = nil then exit;
   SHPData := Data;

   IsItShadow := IsShadow(SHPData^.SHP,Frame);
   if IsItShadow and (ShadowMode) then
      DrawShadowWithFrameImage(SHPData^.SHP,Frame,Zoom,true,false,SHPData^.SHPPalette,SHPData^.Shadow_Match,image1)
   else
      DrawFrameImage(SHPData^.SHP,SHPData^.Shadow_Match,Frame,Zoom,true,false,false,SHPData^.SHPPalette,image1);

   if show_center then // Create Cross
      DrawCenter;

   // OS SHP Builder 3.33: Show Grid (code by PaD, adaptation by Banshee)
   if ShowGrid then // Create Grid -pd
   begin
      DrawGrid;
   end;

   if SelectData.HasSource then
   begin
      Rectangle_dotted(SHPData^.SHP,FrmMain.TempView,FrmMain.Tempview_no,SHPData^.SHPPalette,Frame,SelectData.SourceData.X1,SelectData.SourceData.Y1,SelectData.SourceData.X2,SelectData.SourceData.Y2);
   end;

   if (FrmMain.ActiveForm.Handle = Self.Handle) and (FrmMain.PreviewBrush) then
   begin
      if FrmMain.TempView_no > 0 then
      begin
         // 3.3: Before painting the tempview, we will check
         // which colour will be used to paint it. Putting
         // these things inside a "for" is a big waste of
         // processor power.
         if FrmMain.DrawMode = dmerase then
            Colour := SHPData^.SHPPalette[0]
         else if IsItShadow and (ShadowMode) then
            Colour := SHPData^.SHPPalette[ShadowColour]
         // 3.3: Adition of right click support
         else if (FrmMain.IsClick = 2) and not (DisableBackGround) then
            Colour := SHPData^.SHPPalette[BackGroundColour]
         // end of right click support
         else
            Colour := SHPData^.SHPPalette[ActiveColour];

         // 3.3: Rewritten to Speed up tempview flood
         for x := 0 to (FrmMain.TempView_no-1) do
         begin
            if FrmMain.TempView[x].colour_used then
            begin
               // Set used colour
               image1.Picture.Bitmap.Canvas.Brush.Color := FrmMain.TempView[x].colour;
            end
            else
            begin
               // Set defined colour
               image1.Picture.Bitmap.Canvas.Brush.Color := Colour;
            end;
            image1.Picture.Bitmap.Canvas.FillRect(Rect((FrmMain.TempView[x].X*Zoom),(FrmMain.TempView[x].Y*Zoom),(FrmMain.TempView[x].X*Zoom)+Zoom,(FrmMain.TempView[x].Y*Zoom)+Zoom));
         end;
      end;
      image1.Refresh;
   end;

end;


procedure TFrmSHPImage.SetShadowMode(Value : boolean);
var
   SHPData : TSHPImageData;
begin
   // Get Data
   if Data = nil then exit;
   SHPData := Data;

   // Set shadow mode and menu interface
   Shadowmode := value;
   FrmMain.urnToCameoMode1.Checked := value;
//   FrmMain.AutoShadows1.Enabled := value;
   FrmMain.FixShadows1.Enabled := value;

   // Now, time for the status bar and preview window
   if Shadowmode = false then
   begin
      // It must make sure that the preview exists, to avoid
      // access violations.
      if SHPData^.Preview <> nil then
      begin
         SHPData^.Preview^.TrackBar1.Max := SHPData^.SHP.Header.NumImages;
         SHPData^.Preview^.TrackBar1Change(nil);
      end;
      FrmMain.StatusBar1.Panels[4].Text := 'Shadows Off';
   end
   else
   begin
      // It must make sure that the preview exists, to avoid
      // access violations.
      if SHPData^.Preview <> nil then
      begin
         SHPData^.Preview^.TrackBar1.Max := SHPData^.SHP.Header.NumImages div 2;
         SHPData^.Preview^.TrackBar1Change(nil);
      end;
      FrmMain.StatusBar1.Panels[4].Text := 'Shadows On';
   end;
   FrmMain.SetFrameNumber;

   // Refresh palette (turn 2 to 256 or 256 to 2)
   FrmMain.cnvPalette.Refresh;
   // and refresh the image.
   RefreshImage1;
end;

procedure TFrmSHPImage.SetActiveColour(Col: Integer);
var
   SHPData: TSHPImageData;
begin
     if Data = nil then exit;
     SHPData := Data;
     ActiveColour := Col;
     FrmMain.pnlActiveColour.Color := SHPData^.SHPPalette[ActiveColour];
     FrmMain.lblActiveColour.Caption := IntToStr(ActiveColour) + ' (0x' + IntToHex(ActiveColour,3) + ')';
     FrmMain.cnvPalette.Repaint;
end;

// 3.3: Background Colour adition
procedure TFrmSHPImage.SetBackGroundColour(Col: Integer);
var
   SHPData: TSHPImageData;
begin
   if Data = nil then exit;
   SHPData := Data;
   BackGroundColour := Col;
   if DisableBackGround then
   begin
      FrmMain.lblBackGroundColour.Caption := '< OFF >';
      FrmMain.pnlBackGroundColour.Color := SHPData^.Shadow_Match[BackGroundColour].Original;
   end
   else
   begin
      FrmMain.lblBackGroundColour.Caption := IntToStr(BackGroundColour) + ' (0x' + IntToHex(BackGroundColour,3) + ')';
      FrmMain.pnlBackGroundColour.Color := SHPData^.SHPPalette[BackGroundColour];
   end;
   FrmMain.cnvPalette.Repaint;
end;

// 3.3: Background Colour Activation Adition
procedure TFrmSHPImage.SetBackGround(Value: boolean);
var
   SHPData: TSHPImageData;
begin
   if Data = nil then exit;
   SHPData := Data;
   DisableBackground := Value;
   FrmMain.DisableBackGroundColour1.Checked := not Value;
   FrmMain.pnlBackGroundColour.Enabled := Value;
   if value then
   begin
      FrmMain.lblBackGroundColour.Caption := '< OFF >';
      FrmMain.pnlBackGroundColour.Color := SHPData^.Shadow_Match[BackGroundColour].Original;
   end
   else
   begin
      FrmMain.lblBackGroundColour.Caption := IntToStr(BackGroundColour) + ' (0x' + IntToHex(BackGroundColour,3) + ')';
      FrmMain.pnlBackGroundColour.Color := SHPData^.SHPPalette[BackGroundColour];
  end
end;

procedure TFrmSHPImage.SetShadowColour(Col: Integer);
var
   SHPData : TSHPImageData;
begin
   if Data = nil then exit;
   SHPData := Data;
   if ShadowColour <> Col then
   begin
      if FrmMain.isEditable then
         FrmMain.pnlActiveColour.Color := SHPData^.SHPPalette[Col]
      else
         FrmMain.pnlActiveColour.Color := SHPData^.Shadow_Match[Col].Original;

      ShadowColour := Col;
      FrmMain.lblActiveColour.Caption := IntToStr(ShadowColour) + ' (0x' + IntToHex(ShadowColour,3) + ')';
      FrmMain.cnvPalette.Repaint;
   end;
end;

procedure TFrmSHPImage.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   xx,yy : integer;
   OutOfRange : boolean;
   SHPData : TSHPImageData;
begin
   // Basic stuff:
   if not FrmMain.isEditable then Exit;
   SHPData := Data;

   // Get position
   XX := X;
   YY := Y;
   WorkOutImageClick(SHPData^.SHP,XX,YY,OutOfRange,zoom);

   // 3.36: recoding to make it easier
   // The actions below happen inside the canvas.
   if not OutOfRange then
   begin
      // Let's start with the flood ones instead.
      if (FrmMain.DrawMode = dmflood) then
      begin
         // Reset click and tempview.
         FrmMain.IsClick := 0;
         FrmMain.TempView_no := 0;

         // Add frame to undo
         AddToUndo(SHPData^.UndoList,SHPData^.SHP,Frame);
         FrmMain.UndoUpdate(SHPData^.UndoList);

         if (Button = mbLeft) or (DisableBackGround) then
         begin
            if IsShadow(SHPData^.SHP,Frame) and (ShadowMode) then
               FloodFillTool(SHPData^.SHP,Frame,XX,YY,ShadowColour)
            else
               FloodFillTool(SHPData^.SHP,Frame,XX,YY,ActiveColour);
         end
         else
            FloodFillTool(SHPData^.SHP,Frame,XX,YY,BackGroundColour);
         FrmMain.RefreshAll;
      end
      // 3.36: Flood and Fill With Gradient
      else if (FrmMain.DrawMode = dmFloodGradient) then
      begin
         // Reset click and tempview.
         FrmMain.IsClick := 0;
         FrmMain.TempView_no := 0;

         // Add frame to undo
         AddToUndo(SHPData^.UndoList,SHPData^.SHP,Frame);
         FrmMain.UndoUpdate(SHPData^.UndoList);

         if (Button = mbLeft) or (DisableBackGround) then
         begin
            if IsShadow(SHPData^.SHP,Frame) and (ShadowMode) then
               FloodFillGradientTool(SHPData^.SHP,Frame,XX,YY,SHPData^.SHPPalette,ShadowColour)
            else
               FloodFillGradientTool(SHPData^.SHP,Frame,XX,YY,SHPData^.SHPPalette,ActiveColour);
         end
         else
            FloodFillGradientTool(SHPData^.SHP,Frame,XX,YY,SHPData^.SHPPalette,BackGroundColour);
         FrmMain.RefreshAll;
      end
      // 3.36: Flood and Fill With Blur
      else if (FrmMain.DrawMode = dmFloodBlur) and (not OutOfRange) then
      begin
         // Reset click and tempview.
         FrmMain.IsClick := 0;
         FrmMain.TempView_no := 0;

         // Add frame to undo
         AddToUndo(SHPData^.UndoList,SHPData^.SHP,Frame);
         FrmMain.UndoUpdate(SHPData^.UndoList);

         if (Button = mbLeft) or (DisableBackGround) then
         begin
            if IsShadow(SHPData^.SHP,Frame) and (ShadowMode) then
               FloodFillWithBlur(SHPData^.SHP,Frame,XX,YY,SHPData^.SHPPalette,ShadowColour,FrmMain.alg)
            else
               FloodFillWithBlur(SHPData^.SHP,Frame,XX,YY,SHPData^.SHPPalette,ActiveColour,FrmMain.alg);
         end
         else
            FloodFillWithBlur(SHPData^.SHP,Frame,XX,YY,SHPData^.SHPPalette,BackGroundColour,FrmMain.alg);
         FrmMain.RefreshAll;
      end
      else // Everything else goes here.
      begin
         first.X := XX;
         first.Y := YY;

         // Selection
         // 3.3: Select restricted for left click (Button = mbleft)
         if (Button = mbLeft) and (FrmMain.drawmode = dmselect) and (SelectData.HasSource) then
         begin
            if (XX >= SelectData.SourceData.X1) and (XX <= SelectData.SourceData.X2) and (YY >= SelectData.SourceData.Y1) and (YY <= SelectData.SourceData.Y2) then
            begin
               SelectData.DestData.X1 := SelectData.SourceData.X1;
               SelectData.DestData.X2 := SelectData.SourceData.X2;
               SelectData.DestData.Y1 := SelectData.SourceData.Y1;
               SelectData.DestData.Y2 := SelectData.SourceData.Y2;
               SelectData.MouseClicked.X := XX;
               SelectData.MouseClicked.Y := YY;
               Last.X := XX;
               Last.Y := YY;

               FrmMain.drawmode := dmselectmove;
            end
            else
            begin
               FrmMain.drawmode := dmselect;
               SelectData.HasSource := false;
            end;
         end;

         // 3.3: Set IsClick (replace FrmMain.IsLeftMouse=true)
         if (Button = mbLeft) or (DisableBackGround) then
            FrmMain.IsClick := 1
         else
            FrmMain.IsClick := 2;
         Image1MouseMove(Sender,Shift,X,Y);
      end;
   end;
end;

procedure TFrmSHPImage.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   OutOfRange : boolean;
   XX,YY,XDifference,YDifference : integer;
   Colour : byte;
   SHPData : TSHPImageData;
begin
   // OS SHP Builder 3.3: This function has been reformulated
   // and re-documented for right click support.

   // You can't move something that doesn't exist.
   if not FrmMain.isEditable then Exit;

   // Data exists.
   SHPData := Data;

   // Basic drawing (Get Mouse Position)
   XX := X;
   YY := Y;
   WorkOutImageClick(SHPData^.SHP,XX,YY,OutOfRange,zoom);

   // Update status bar with mouse position.
   if not OutOfRange then
     FrmMain.StatusBar1.Panels[2].Text := 'X: ' + inttostr(XX) + ' Y: ' + inttostr(YY);

   // Set colour;
   if IsShadow(SHPData^.SHP,Frame) and (ShadowMode) then
      Colour := ShadowColour
   else
   begin
      if (FrmMain.IsClick = 2)  and (not DisableBackGround) then // Right click
         Colour := BackGroundColour
      else // Left click, default.
         Colour := ActiveColour;
   end;

   if FrmMain.IsClick = 0 then
   begin
      FrmMain.TempView_no := 0; // Empty the temp view (well its still got the previous data, but it saves emptying it.)
      SetLength(FrmMain.TempView,0);
      // In here are tools that show a preview when the mouse
      //  is moved and isn't clicked.

      // The tools below can be previewed when they are out of range:
      case FrmMain.DrawMode of
         dmCrash:
         begin
            Crash(SHPData^.SHP,SHPData^.SHPPalette,FrmMain.TempView,FrmMain.TempView_no,XX,YY,Frame,FrmMain.alg);
            LastPreview.X := XX;
            LastPreview.Y := YY;
            RefreshImage1;
         end;

         dmLightCrash:
         begin
            CrashLight(SHPData^.SHP,SHPData^.SHPPalette,FrmMain.TempView,FrmMain.TempView_no,XX,YY,Frame,FrmMain.alg);
            LastPreview.X := XX;
            LastPreview.Y := YY;
            RefreshImage1;
         end;

         dmBigCrash:
         begin
            CrashBig(SHPData^.SHP,SHPData^.SHPPalette,FrmMain.TempView,FrmMain.TempView_no,XX,YY,Frame,FrmMain.alg);
            LastPreview.X := XX;
            LastPreview.Y := YY;
            RefreshImage1;
         end;

         dmBigLightCrash:
         begin
            CrashBigLight(SHPData^.SHP,SHPData^.SHPPalette,FrmMain.TempView,FrmMain.TempView_no,XX,YY,Frame,FrmMain.alg);
            LastPreview.X := XX;
            LastPreview.Y := YY;
            RefreshImage1;
         end;

         dmDirty:
         begin
            Dirty(SHPData^.SHP,SHPData^.SHPPalette,FrmMain.TempView,FrmMain.TempView_no,XX,YY,Frame,FrmMain.alg);
            LastPreview.X := XX;
            LastPreview.Y := YY;
            RefreshImage1;
         end;

         dmSnow:
         begin
            Snow(SHPData^.SHP,SHPData^.SHPPalette,FrmMain.TempView,FrmMain.TempView_no,XX,YY,Frame,FrmMain.alg);
            LastPreview.X := XX;
            LastPreview.Y := YY;
            RefreshImage1;
         end;
      end; // End of case

      // Now we have the tools that can only be previewed when
      // they are in range.
      if not OutOfRange then
      begin
         case FrmMain.DrawMode of
            dmDraw:
               // Note: Doesn't preview spray (brush type 4)
               if FrmMain.Brush_Type <> 4 then
               begin
                  BrushTool(SHPData^.SHP,FrmMain.TempView,FrmMain.TempView_no,XX,YY,FrmMain.Brush_Type,Colour);
                  RefreshImage1;
               end;

            dmErase:
                if FrmMain.Brush_Type <> 4 then
                begin
                   // Erase is the same as draw but it is
                   // always the transparent colour...
                   BrushTool(SHPData^.SHP,FrmMain.TempView,FrmMain.TempView_no,XX,YY,FrmMain.Brush_Type,0);
                   RefreshImage1;
                end;

             dmselect:
             begin
                if (Image1.Cursor <> MouseMoveC) and (Image1.Cursor <> DefultCursor) then
                    DefultCursor := Image1.Cursor;

                if SelectData.HasSource then
                begin
                   if (XX >= SelectData.SourceData.X1) and (XX <= SelectData.SourceData.X2) and (YY >= SelectData.SourceData.Y1) and (YY <= SelectData.SourceData.Y2) then
                      Image1.Cursor := MouseMoveC
                   else
                      Image1.Cursor := DefultCursor;
                end;
             end;
          end;
      end; // End of non-out of range tools
// Note: I don't see any sense for this part, as it only
// previews and doesn't overwrite the image.
{
      else
         if (FrmMain.DrawMode <> dmselect) and (FrmMain.DrawMode <> dmselectmove) then
            FrmMain.RefreshAll;
}
   end
   else if FrmMain.IsClick > 0 then
   begin
   // Here we have the tools that preview once you click
      if not OutOfRange then
      begin
      // Now the tools that you preview only on range.

         case FrmMain.DrawMode of
            dmDraw:
            begin
               BrushTool(SHPData^.SHP,FrmMain.TempView,FrmMain.TempView_no,XX,YY,FrmMain.Brush_Type,Colour);
               RefreshImage1;
            end;

            dmErase:
            begin
            // Erase is the same as draw but it is always the transparent colour...
               BrushTool(SHPData^.SHP,FrmMain.TempView,FrmMain.TempView_no,XX,YY,FrmMain.Brush_Type,0);
               RefreshImage1;
            end;

            dmdropper:
            begin
               if IsShadow(SHPData^.SHP,Frame) and (shadowmode) then
                  SetShadowColour(SHPData^.SHP.Data[Frame].FrameImage[XX,YY])
               else if (FrmMain.IsClick = 1) or DisableBackground then
                  SetActiveColour(SHPData^.SHP.Data[Frame].FrameImage[XX,YY])
               else
                  SetBackGroundColour(SHPData^.SHP.Data[Frame].FrameImage[XX,YY]);
            end;

            dmline:
            begin
               if (Last.X <> XX) or (Last.Y <> YY) then // Only if the last value has changed then refresh
               begin
                  Last.X := XX;
                  Last.Y := YY;
                  DrawLine(FrmMain.TempView,FrmMain.TempView_no,last,first);
                  RefreshImage1;
               end;
            end;

            dmRectangle:
            begin
               if (Last.X <> XX) or (Last.Y <> YY) then // Only if the last value has changed then refresh
               begin
                  Last.X := XX;
                  Last.Y := YY;
                  // Shifty square trick
                  if (Shift >= [ssShift]) then
                     Rectangle(FrmMain.TempView, FrmMain.Tempview_no,First.X,First.Y,First.X + Abs(Min(Last.X - First.X,Last.Y - First.Y)),First.Y + Min(Last.X - First.X,Last.Y - First.Y),False)
                  else
                     Rectangle(FrmMain.TempView, FrmMain.Tempview_no,First.X,First.Y,Last.X,Last.Y,False);
                  RefreshImage1;
               end;
            end;

            dmRectangle_Fill:
            begin
               if (Last.X <> XX) or (Last.Y <> YY) then // Only if the last value has changed then refresh
               begin
                  Last.X := XX;
                  Last.Y := YY;
                  // The shifty square trick
                  if (Shift >= [ssShift]) then
                     Rectangle(FrmMain.TempView, FrmMain.Tempview_no,First.X,First.Y,First.X + Abs(Min(Last.X - First.X,Last.Y - First.Y)),First.Y + Min(Last.X - First.X,Last.Y - First.Y),True)
                  else
                     Rectangle(FrmMain.TempView,FrmMain.Tempview_no,First.X,First.Y,Last.X,Last.Y,True);
                  RefreshImage1;
               end;
            end;

            dmElipse:
            begin
               if (Last.X <> XX) or (Last.Y <> YY) then // Only if the last value has changed then refresh
               begin
                  Last.X := XX;
                  Last.Y := YY;
                  // The shifty circle trick
                  if (Shift >= [ssShift]) then
                     Elipse(FrmMain.TempView,FrmMain.Tempview_no,First.X,First.Y,First.X + Abs(Min(Last.X - First.X,Last.Y - First.Y)),First.Y + Min(Last.X - First.X,Last.Y - First.Y),False)
                  else
                     Elipse(FrmMain.TempView,FrmMain.Tempview_no,First.X,First.Y,Last.X,Last.Y,False);
                  RefreshImage1;
               end;
            end;

            dmElipse_Fill:
            begin
               if (Last.X <> XX) or (Last.Y <> YY) then // Only if the last value has changed then refresh
               begin
                  Last.X := XX;
                  Last.Y := YY;
                  // The shifty circle trick
                  if (Shift >= [ssShift]) then
                     Elipse(FrmMain.TempView,FrmMain.Tempview_no,First.X,First.Y,First.X + Abs(Min(Last.X - First.X,Last.Y - First.Y)),First.Y + Min(Last.X - First.X,Last.Y - First.Y),True)
                  else
                     Elipse(FrmMain.TempView,FrmMain.Tempview_no,First.X,First.Y,Last.X,Last.Y,True);
                  RefreshImage1;
               end;
            end;

            dmselect:
            begin
               // 3.3: Select only occurs on left click
               if (FrmMain.IsClick = 1) and ((Last.X <> XX) or (Last.Y <> YY)) then // Only if the last value has changed then refresh
               begin
                  Last.X := XX;
                  Last.Y := YY;
                  Rectangle_dotted(SHPData^.SHP,FrmMain.TempView,FrmMain.Tempview_no,SHPData^.SHPPalette,Frame,First.X,First.Y,Last.X,Last.Y);
                  RefreshImage1;
               end;
            end;

            dmselectmove:
            begin
            //if (Last.X <> XX) or (Last.Y <> YY) then // Only if the last value has changed then refresh
               // 3.3: Restrict activity for left click;
               if FrmMain.IsClick = 1 then
               begin
                  Last.X := XX;
                  Last.Y := YY;

                  XDifference := XX-SelectData.MouseClicked.X;
                  YDifference := YY-SelectData.MouseClicked.Y;

                  SelectData.DestData.X1 := SelectData.SourceData.X1 + XDifference;
                  SelectData.DestData.X2 := SelectData.SourceData.X2 + XDifference;
                  SelectData.DestData.Y1 := SelectData.SourceData.Y1 + YDifference;
                  SelectData.DestData.Y2 := SelectData.SourceData.Y2 + YDifference;

                  Rectangle_dotted(SHPData^.SHP,FrmMain.TempView,FrmMain.TempView_no,SHPData^.SHPPalette,Frame,SelectData.DestData.X1,SelectData.DestData.Y1,SelectData.DestData.X2,SelectData.DestData.Y2);
                  RefreshImage1;
               end; // end of IsClick = 1.
            end;
         end; // end of case
      end; // End of Out Of Range
   end; // End of clicked stuff
end; // End Of Procedure

procedure TFrmSHPImage.Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   xx,yy : integer;
   OutOfRange : boolean;
   SHPData : TSHPImageData;
   Colour : byte;
begin
   // OS SHP Builder 3.3: This function has been reformulated
   // and re-documented for right click support.

   // 3.31: Just to make sure nothing wrong will happen.
   if not FrmMain.isEditable then exit;

   // Without clicks, nothing changes.
   if FrmMain.IsClick = 0 then Exit;

   // Get SHP Data. (Kinda useless, but helps with pointer operations)
   SHPData := Data;

   // Get Mouse Position:
   XX := X;
   YY := Y;
   WorkOutImageClick(SHPData^.SHP,XX,YY,OutOfRange,zoom);


   // Time for non-selection stuff
   if (FrmMain.drawmode <> dmselect) and (FrmMain.drawmode <> dmselectmove) then
   begin
      // Paint tempview related tools.
      if FrmMain.TempView_no > 0 then
      begin
         // Confirm Undo from tempview for these tools
         AddToUndo(SHPData^.UndoList,SHPData^.SHP,FrmMain.TempView,FrmMain.TempView_no,SHPData^.SHP.Data[Frame].FrameImage,Frame);
         FrmMain.UndoUpdate(SHPData^.UndoList);
         // Act accordingly for each tool (we could use case here)
         case (FrmMain.DrawMode) of
            dmCrash: Crash(SHPData^.SHP,SHPData^.SHPPalette,LastPreview.X,LastPreview.Y,Frame,FrmMain.alg);
            dmLightCrash: CrashLight(SHPData^.SHP,SHPData^.SHPPalette,LastPreview.X,LastPreview.Y,Frame,FrmMain.alg);
            dmBigCrash: CrashBig(SHPData^.SHP,SHPData^.SHPPalette,LastPreview.X,LastPreview.Y,Frame,FrmMain.alg);
            dmBigLightCrash: CrashBigLight(SHPData^.SHP,SHPData^.SHPPalette,LastPreview.X,LastPreview.Y,Frame,FrmMain.alg);
            dmDirty: Dirty(SHPData^.SHP,SHPData^.SHPPalette,LastPreview.X,LastPreview.Y,Frame,FrmMain.alg);
            dmSnow: Snow(SHPData^.SHP,SHPData^.SHPPalette,LastPreview.X,LastPreview.Y,Frame,FrmMain.alg);
            else // Other tools, like brush, erase, etc...
            begin
               if FrmMain.DrawMode= dmerase then
                  Colour := 0
               // 3.3: Background Colour adition
               else if IsShadow(SHPData^.SHP,Frame) and (ShadowMode) then
                  Colour := ShadowColour
               else if (FrmMain.IsClick = 2) and (not DisableBackGround) then
                  Colour := BackGroundColour
               else
                  Colour := ActiveColour;

               for xx := 0 to (FrmMain.TempView_no-1) do
                  SHPData^.SHP.Data[Frame].FrameImage[FrmMain.TempView[xx].X,FrmMain.TempView[xx].Y] := Colour;
            end;
         end;
         FrmMain.TempView_no := 0;
      end // End of tempview related tools
      // Darken & Lighten doesn't use tempview, so it goes here!
      else if FrmMain.DrawMode = dmdarkenlighten then
      begin
         if not OutOfRange then
         begin
            BrushToolDarkenLighten(SHPData^.SHP,FrmMain.TempView,FrmMain.TempView_no,Frame,XX,YY,FrmMain.Brush_Type);
            AddToUndo(SHPData^.UndoList,FrmMain.TempView,FrmMain.TempView_no,Frame,SHPData^.SHP.Header.Width,SHPData^.SHP.Header.Height);
            FrmMain.UndoUpdate(SHPData^.UndoList);
         end;
      end
      else if FrmMain.DrawMode = dmdropper then
      begin
         if IsShadow(SHPData^.SHP,Frame) and (ShadowMode) then
            SetShadowColour(SHPData^.SHP.Data[Frame].FrameImage[XX,YY])
         else if (FrmMain.IsClick = 2) and (not DisableBackGround) then
            SetBackGroundColour(SHPData^.SHP.Data[Frame].FrameImage[XX,YY])
         else
            SetActiveColour(SHPData^.SHP.Data[Frame].FrameImage[XX,YY]);
      end;
      // Reset click state:
      FrmMain.IsClick := 0;
   end // End of non-selection tools
   else if FrmMain.drawmode = dmselect then
   begin
      // 3.3: Selection occurs only on left click:
      if FrmMain.IsClick = 1 then
      begin
         if SelectData.HasSource = false then
         begin
            // If the square is null, do nothing.
            if (first.x = last.x) and (first.y = last.y) then
            begin
               FrmMain.TempView_no := 0;
               FrmMain.IsClick := 0;
            end
            else
            begin
               // else, it set it up.
               SelectData.HasSource := true;
               SelectData.SourceData.X1 := min(first.x,last.x);
               SelectData.SourceData.X2 := max(first.x,last.x);
               SelectData.SourceData.Y1 := min(first.y,last.y);
               SelectData.SourceData.Y2 := max(first.y,last.y);
               //- Removed: FrmMain.DrawMode := dmselectmove;
               // Reset click
               FrmMain.IsClick := 0;
            end;
         end
         else
         begin
            FrmMain.IsClick := 0;
            SelectData.HasSource := false;
         end;
      end
      else
      begin
         // Right click cancels operation.
         FrmMain.IsClick := 0;
         SelectData.HasSource := false;
      end;
   end
   else if FrmMain.DrawMode = dmselectmove then
   begin
      // 3.3: Selection move occurs only on left click:
      if FrmMain.IsClick = 1 then
      begin
         AddToUndo(SHPData^.Undolist,SHPData^.SHP,Frame,SelectData.SourceData,SelectData.DestData);
         FrmMain.UndoUpdate(SHPData^.UndoList);
         // 3.3: Added support for transparent copy and paste.
         if DisableBackground then
            FrameImage_Section_Move(SHPData^.SHP,Frame,SelectData.SourceData,SelectData.DestData)
         else
            FrameImage_Section_Move(SHPData^.SHP,Frame,SelectData.SourceData,SelectData.DestData,BackGroundColour);
         FrmMain.DrawMode := dmselect;
         SelectData.SourceData.X1 := SelectData.DestData.X1;
         SelectData.SourceData.X2 := SelectData.DestData.X2;
         SelectData.SourceData.Y1 := SelectData.DestData.Y1;
         SelectData.SourceData.Y2 := SelectData.DestData.Y2;
         FrmMain.IsClick := 0;
      end
      else
      begin
         // Right click cancel the operation.
         FrmMain.IsClick := 0;
         FrmMain.drawmode := dmselect;
         SelectData.HasSource := false;
      end;
   end;
   FrmMain.RefreshAll;
end;

procedure TFrmSHPImage.FormClose(Sender: TObject; var Action: TCloseAction);
var
   x : TSHPImages;
begin
   // 3.36: Fix closure MDI problems if the window state is
   // not normal.
   WindowState := wsNormal;

   // 3.31: Lock program:
   FrmMain.SetIsEditable(false);
   self.Enabled := false;

   // Remove window menu item related to this editing window.
   FrmMain.RemoveNewWindowMenu(FrmMain.ActiveForm^);

   // Close window.
   FrmMain.CloseClientWindow;

   // final note: TotalImages doesnt drop, so the IDs will
   // always be unique
   action := caFree;
end;

procedure TFrmSHPImage.AutoGetCursor;
begin
   if (FrmMain.SpbDraw.Down) or (FrmMain.SpbErase.Down) or (FrmMain.SpbDarkenLighten.Down) then
   begin
      if FrmMain.Brush_Type = 0 then
         Image1.Cursor := MouseDraw
      else if FrmMain.Brush_Type = 4 then
         Image1.Cursor := MouseSpray
      else
         Image1.Cursor := MouseBrush;
   end
   else if (FrmMain.SpbLine.Down) or (FrmMain.SpbFramedRectangle.Down) or (FrmMain.SpbElipse.Down) or (FrmMain.SpbBuildingTools.Down) then
   begin
      Image1.Cursor := MouseLine;
   end
   else if (FrmMain.SpbFloodFill.Down) then
   begin
      Image1.Cursor := MouseFill;
   end
   else if (FrmMain.SpbColorSelector.Down) then
   begin
      Image1.Cursor := MouseDropper;
   end
   else if (FrmMain.SpbSelect.Down) then
   begin
      Image1.Cursor := CrArrow;
   end
   else
      Image1.Cursor := MouseDraw;
end;


procedure TFrmSHPImage.FormShow(Sender: TObject);
begin
   ActiveColour := 16;
   ShadowColour := 1;
   SetActiveColour(ActiveColour);

// ScrollBox1.DoubleBuffered := true;
   if FrmMain.ActiveForm = nil then
      AutoGetCursor
   else
      Image1.Cursor := FrmMain.ActiveForm^.Image1.Cursor;

   Zoom := 1; // default value
   Frame := 1; // default value
end;

// 3.35: This function updates the second status bar area
// with SHP Type and Game.
procedure TFrmSHPImage.WriteSHPType;
begin
   FrmMain.StatusBar1.Panels[1].Text := 'SHP Type: ' + GetSHPType(TSHPImageData(Data)^.SHP) +  '(' + GetSHPGame(TSHPImageData(Data)^.SHP) + ')';
end;

// 3.35: This function will validate the SHP Type according to
// the new game selected by user.
procedure TFrmSHPImage.UpdateSHPTypeFromGame;
var
   SHPData : TSHPImageData;
begin
   // Helps to retrive SHP data.
   if Data = nil then exit;   
   SHPData := Data;

   // Check Game.
   case (SHPData^.SHP.SHPGame) of
      sgTD:
      begin // That's the conversion table for TD
         case (SHPData^.SHP.SHPType) of
            stTem: SHPData^.SHP.SHPType := stDes;
            stSno: SHPData^.SHP.SHPType := stWin;
            stInt: SHPData^.SHP.SHPType := stDes;
            stUrb: SHPData^.SHP.SHPType := stDes;
            stLun: SHPData^.SHP.SHPType := stWin;
            stNewUrb: SHPData^.SHP.SHPType := stDes;
         end;
      end;
      sgRA1:
      begin // That's the conversion table for RA1
         case (SHPData^.SHP.SHPType) of
            stDes: SHPData^.SHP.SHPType := stTem;
            stWin: SHPData^.SHP.SHPType := stSno;
            stUrb: SHPData^.SHP.SHPType := stInt;
            stLun: SHPData^.SHP.SHPType := stSno;
            stNewUrb: SHPData^.SHP.SHPType := stInt;
         end;
      end;
      sgTS:
      begin // That's the conversion table for TS
         case (SHPData^.SHP.SHPType) of
            stDes: SHPData^.SHP.SHPType := stTem;
            stWin: SHPData^.SHP.SHPType := stSno;
            stInt: SHPData^.SHP.SHPType := stTem;
            stUrb: SHPData^.SHP.SHPType := stTem;
            stLun: SHPData^.SHP.SHPType := stSno;
            stNewUrb: SHPData^.SHP.SHPType := stTem;
         end;
      end;
      sgRA2:
      begin // RA2 doesn't support is Interior.
         if SHPData^.SHP.SHPType = stInt then
            SHPData^.SHP.SHPType := stUrb;
      end;
   end;
end;

// 3.35: This function updates the Options -> SHP Type menu.
procedure TFrmSHPImage.UpdateSHPTypeMenu;
var
   SHPData : TSHPImageData;
begin
   // Helps to retrive SHP data.
   if Data = nil then exit;
   SHPData := Data;

   // Uncheck the old selected type.
   if FrmMain.CurrentSHPType <> nil then
      FrmMain.CurrentSHPType^.checked := false;

   FrmMain.SHPTypeMenuTD.Checked := false;
   FrmMain.SHPTypeTDNone.Checked := true;
   FrmMain.SHPTypeMenuRA1.Checked := false;
   FrmMain.SHPTypeRA1None.Checked := true;
   FrmMain.SHPTypeMenuTS.Checked := false;
   FrmMain.SHPTypeTSNone.Checked := true;
   FrmMain.SHPTypeMenuRA2.Checked := false;
   FrmMain.SHPTypeRA2None.Checked := true;
   FrmMain.FixShadows1.Enabled := false;

   // We determine the menu item by checking game and type.
   case (SHPData^.SHP.SHPGame) of
      sgTD:
      begin // If the game is Tiberian Dawn:
         FrmMain.SHPTypeMenuTD.Checked := true;
         FrmMain.SHPTypeTDNone.Checked := false;
         FrmMain.RedToRemapable1.Checked := false;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDUnit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDBuilding;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDBuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDAnimation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDCameo;
            stDes: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDDesert;
            stWin: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDWinter;
         end; // end of TD Type case.
      end; // End of TD
      sgRA1:
      begin // If the game is Red Alert 1:
         FrmMain.SHPTypeMenuRA1.Checked := true;
         FrmMain.SHPTypeRA1None.Checked := false;
         FrmMain.RedToRemapable1.Checked := false;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Unit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Building;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1BuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Animation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Cameo;
            stTem: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Temperate;
            stSno: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Snow;
            stInt: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Interior;
         end; // end of RA1 Type case.
      end; // End of RA1
      sgTS:
      begin // If the game is Tiberian Sun
         FrmMain.SHPTypeMenuTS.Checked := true;
         FrmMain.SHPTypeTSNone.Checked := false;
         FrmMain.FixShadows1.Enabled := true;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSUnit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSBuilding;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSBuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSAnimation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSCameo;
            stTem: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSTemperate;
            stSno: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSSnow;
         end; // end of TS Type case.
      end; // End of TS
      sgRA2:
      begin // If the game is Red Alert 2
         FrmMain.SHPTypeMenuRA2.Checked := true;
         FrmMain.SHPTypeRA2None.Checked := false;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Unit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Building;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2BuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Animation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Cameo;
            stTem: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Temperate;
            stSno: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Snow;
            stUrb: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Urban;
            stDes: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Desert;
            stLun: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Lunar;
            stNewUrb: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2NewUrban;
         end; // end of TS Type case.
      end; // End of TS
   end; // end of case.

   FrmMain.CurrentSHPType^.Checked := true;
end;

procedure TFrmSHPImage.FormActivate(Sender: TObject);
begin
   // Update ActiveData & ActiveForm
   if not FrmMain.isEditable then exit;
   if FrmMain.ActiveForm <> nil then
      Image1.Cursor := FrmMain.ActiveForm^.Image1.Cursor;
   FrmMain.ActiveForm := Address;
   FrmMain.ActiveData := Data;
   SetFocus;
   BringToFront;
   // Update Zoom and Frame
   FrmMain.Zoom_Factor.MaxValue := MaxZoom;
   FrmMain.Zoom_Factor.Value := Zoom;
   FrmMain.Current_Frame.Value := Frame;
   if caption = '' then exit;
   // Update Palette
   if FrmMain.ActiveData^.Filename <> FrmMain.CurrentPaletteID then
      FrmMain.cnvPalette.Repaint;
   // Update Active/Shadow Colours
   SetShadowMode(shadowmode);
   if IsShadow(FrmMain.ActiveData^.SHP,Frame) then
   begin
      FrmMain.lblActiveColour.Caption := IntToStr(ShadowColour) + ' (0x' + IntToHex(ShadowColour,3) + ')';
      FrmMain.pnlActiveColour.Color := FrmMain.ActiveData^.SHPPalette[ShadowColour];
   end
   else
   begin
      FrmMain.pnlActiveColour.Color := FrmMain.ActiveData^.SHPPalette[ActiveColour];
      FrmMain.lblActiveColour.Caption := IntToStr(ActiveColour) + ' (0x' + IntToHex(ActiveColour,3) + ')';
   end;
   // 3.3: BackGround Colour update
   FrmMain.lblBackGroundColour.Caption := IntToStr(BackGroundColour) + ' (0x' + IntToHex(BackGroundColour,3) + ')';
   FrmMain.pnlBackGroundColour.Color := FrmMain.ActiveData^.SHPPalette[BackGroundColour];
   FrmMain.DisableBackGroundColour1.Checked := not DisableBackGround;
   FrmMain.pnlBackGroundColour.Enabled := DisableBackGround;
   // Update Undo
   FrmMain.UndoUpdate(FrmMain.ActiveData^.UndoList);
   // Update Show Center Button
   FrmMain.TbShowCenter.Down := self.show_center;
   // Update Preview Button
   if FrmMain.ActiveData^.Preview = nil then
   begin
      FrmMain.Preview1.Checked := false;
      FrmMain.TbPreviewWindow.Down := false;
   end
   else
   begin
      FrmMain.Preview1.Checked := true;
      FrmMain.TbPreviewWindow.Down := true;
   end;

   // Update StatusBar
//   FrmMain.StatusBar1.Panels[1].Text := 'SHP Type: ' + GetSHPType(FrmMain.ActiveData^.SHP);
   WriteSHPType;
   UpdateSHPTypeMenu;
   FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + inttostr(FrmMain.ActiveData^.SHP.Header.Width) + ' Height: ' + inttostr(FrmMain.ActiveData^.SHP.Header.Height);
end;

procedure TFrmSHPImage.FormResize(Sender: TObject);
var
   SHPData: TSHPImageData;
   width, height : word;
begin

   if C or (Data = nil) then
   begin
      C := False;
      ScrollBox1.HorzScrollBar.Visible := false;
      ScrollBox1.VertScrollBar.Visible := false;
      ScrollBox1.HorzScrollBar.Range := 0;
      ScrollBox1.VertScrollBar.Range := 0;
      Exit;
   end;

   SHPData := Data;

   // Cache basic values
   width := SHPData^.SHP.header.Width * Zoom;
   height := SHPData^.SHP.header.Height * Zoom;

   if ClientWidth < Width then
   begin
      ScrollBox1.HorzScrollBar.Visible := true;
      ScrollBox1.HorzScrollBar.Range := Width;
   end
   else
      ScrollBox1.HorzScrollBar.Visible := false;

   if ClientHeight < Height then
   begin
      ScrollBox1.VertScrollBar.Visible := true;
      ScrollBox1.VertScrollBar.Range := Height;
   end
   else
      ScrollBox1.VertScrollBar.Visible := false;
end;

procedure TFrmSHPImage.FormCreate(Sender: TObject);
begin
   C := True;
   Width := 0;
   Height := 0;
   PaintAreaPanel.Width := 0;
   PaintAreaPanel.Height := 0;

   ScrollBox1.DoubleBuffered := true;
   PaintAreaPanel.DoubleBuffered := true;
//   Resize;
end;

Procedure TFrmSHPImage.WorkOutImageClick(var SHP: TSHP; var X,Y : integer; var OutOfRange : boolean; zoom:byte);
begin
   OutOfRange := true; // Assume True

   x := (x div zoom);
   y := (y div zoom);

   if not ((x >= shp.Header.Width) or (y >= shp.Header.Height) or (x < 0) or (y < 0)) then
      OutOfRange := false;
end;


end.
