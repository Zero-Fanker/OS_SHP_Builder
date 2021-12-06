unit FormGifOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, XPMan;

type
  TFrmGifOptions = class(TForm)
    LoopType: TRadioGroup;
    BtOK: TButton;
    BtCancel: TButton;
    Shadows: TRadioGroup;
    GroupBox1: TGroupBox;
    Zoom_Factor: TSpinEdit;
    Transparency: TGroupBox;
    CbUseTransparency: TCheckBox;
    XPManifest: TXPManifest;
    Quantization: TRadioGroup;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Changed : Boolean;
  end;

implementation

{$R *.dfm}

procedure TFrmGifOptions.BtOKClick(Sender: TObject);
begin
   Changed := True;
   Close;
end;

procedure TFrmGifOptions.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmGifOptions.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFrmGifOptions.FormShow(Sender: TObject);
begin
   Changed := False;
end;

end.
