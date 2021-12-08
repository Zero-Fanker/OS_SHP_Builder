unit FormNew;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   StdCtrls, ExtCtrls, Spin, ComCtrls, XPMan;

type
   TFrmNew = class(TForm)
      grpCurrentSize: TGroupBox;
      Label2:    TLabel;
      Label3:    TLabel;
    BtOK: TButton;
    BtCancel: TButton;
      Label1:    TLabel;
      txtWidth:  TSpinEdit;
      txtHeight: TSpinEdit;
      txtFrames: TSpinEdit;
      CbxGame:   TComboBoxEx;
      Label4:    TLabel;
      CbxType:   TComboBoxEx;
      Label5:    TLabel;
    XPManifest: TXPManifest;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure BtCancelClick(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure txtWidthChange(Sender: TObject);
      procedure txtHeightChange(Sender: TObject);
      procedure txtFramesChange(Sender: TObject);
      procedure CbxGameChange(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      x, y, z:  integer; //size of voxel section currently
      changed, //has x,y or z changed at all? if not, no need to do anything
      dataloss: boolean; //and if changed, will this result in any voxels being lost?
   end;

implementation

{$R *.DFM}

uses FormMain;

procedure TFrmNew.BtCancelClick(Sender: TObject);
begin
   changed := False;
   Close;
end;

procedure TFrmNew.BtOKClick(Sender: TObject);
begin
   changed := True;
   Close;
end;

procedure TFrmNew.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = VK_RETURN then
   begin
      BtOkClick(Sender);
   end
   else if Key = VK_ESCAPE then
   begin
      BtCancelClick(Sender);
   end;
end;

procedure TFrmNew.FormShow(Sender: TObject);
begin
   changed := False;
   CbxGame.Images := FrmMain.ImageList;
   CbxGame.ItemIndex := 2;
   CbxType.ItemIndex := 0;
end;

procedure TFrmNew.txtWidthChange(Sender: TObject);
begin
   if txtWidth.Text = '' then
      txtWidth.Text := '1'
   else if txtWidth.Value > 10000 then
      txtWidth.Value := 10000;

end;

procedure TFrmNew.txtHeightChange(Sender: TObject);
begin
   if txtHeight.Text = '' then
      txtHeight.Text := '1'
   else if txtHeight.Value > 10000 then
      txtHeight.Value := 10000;
end;

procedure TFrmNew.txtFramesChange(Sender: TObject);
begin
   if txtFrames.Text = '' then
      txtFrames.Text := '1'
   else if txtFrames.Value > 10000 then
      txtFrames.Value := 10000;
end;


procedure TFrmNew.CbxGameChange(Sender: TObject);
var
   Index: integer;
begin
   Index := CbxType.ItemIndex;
   case (CbxGame.ItemIndex) of
      0:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Desert)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Winter)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
      1:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Temperate)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Snow)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Interior)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
      2:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Temperate)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Snow)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
      3:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Temperate)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Snow)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Urban)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Desert)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Lunar)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (New Urban)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
   end;
end;

end.
