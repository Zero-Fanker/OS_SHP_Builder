unit FormExportFramesAsImage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, XPMan;

type
  TFrmExportFramesAsImage = class(TForm)
    SpeFrom: TSpinEdit;
    SpeTo: TSpinEdit;
    lblFrom: TLabel;
    lblTo: TLabel;
    Bevel1: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    BtToEnd: TButton;
    BtToOne: TButton;
    XPManifest: TXPManifest;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure BtToEndClick(Sender: TObject);
    procedure BtToOneClick(Sender: TObject);
    procedure SpeToChange(Sender: TObject);
    procedure SpeFromChange(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
    PLastFocus : ^TSpinEdit;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}
uses FormMain;

procedure TFrmExportFramesAsImage.BtCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmExportFramesAsImage.BtOKClick(Sender: TObject);
begin
   // Execute Export here.
   if StrToIntDef(SpeFrom.Text,0) > 0 then
      if StrToIntDef(SpeTo.Text,0) > 0 then
      begin
         FrmMain.ExportSHPAsImages(SpeFrom.Value,SpeTo.Value);
         close;
         exit;
      end;
   ShowMessage('Error! Invalid Frames.');
end;

procedure TFrmExportFramesAsImage.BtToEndClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MaxValue;
end;

procedure TFrmExportFramesAsImage.BtToOneClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MinValue;
end;

procedure TFrmExportFramesAsImage.FormCreate(Sender: TObject);
begin
   speFrom.Increment := 1;
   speTo.Increment := 1;
   speFrom.MinValue := 1;
   speTo.MinValue := SpeFrom.MinValue;
   speFrom.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   speTo.MaxValue := SpeFrom.MaxValue;
   speTo.Value := FrmMain.ActiveForm^.Frame;
   speFrom.Value := FrmMain.ActiveForm^.Frame;
   PLastFocus := @speFrom;
end;

procedure TFrmExportFramesAsImage.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFrmExportFramesAsImage.SpeFromChange(Sender: TObject);
begin
   if SpeFrom.Value < 1 then
      SpeFrom.Value := 1
   else if SpeFrom.Value > speTo.Value then
      SpeFrom.Value := SpeTo.Value;
   PLastFocus := @speFrom;
end;

procedure TFrmExportFramesAsImage.SpeToChange(Sender: TObject);
begin
   if SpeTo.Value < speFrom.Value then
      SpeTo.Value := speFrom.Value
   else if SpeTo.Value > speTo.MaxValue then
      SpeTo.Value := SpeTo.MaxValue;
   PLastFocus := @speTo;
end;

end.
