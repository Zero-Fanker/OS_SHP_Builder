unit FormDarkenLightenTool;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, XPMan;

type
   Tfrmdarkenlightentool = class(TForm)
      Label1:    TLabel;
      ComboBox1: TComboBox;
    BtOK: TButton;
    BtCancel: TButton;
    XPManifest: TXPManifest;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure BtOKClick(Sender: TObject);
      procedure BtCancelClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

implementation

uses FormMain;

{$R *.dfm}

procedure Tfrmdarkenlightentool.BtOKClick(Sender: TObject);
begin
   FrmMain.DarkenLighten_N := ComboBox1.ItemIndex + 1;
   Close;
end;

procedure Tfrmdarkenlightentool.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure Tfrmdarkenlightentool.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure Tfrmdarkenlightentool.FormShow(Sender: TObject);
begin
   ComboBox1.ItemIndex := FrmMain.DarkenLighten_N - 1;
end;

end.
