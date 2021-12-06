unit FormPreferences_Anim;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ExtCtrls, StdCtrls, Spin, XPMan;

type
   TFrmPreferences_Anim = class(TForm)
      Label1:  TLabel;
      Name:    TEdit;
      Label2:  TLabel;
      Label3:  TLabel;
      Count:   TSpinEdit;
      Count2:  TSpinEdit;
      Label4:  TLabel;
      Label5:  TLabel;
      StartFrame: TSpinEdit;
      Special: TEdit;
    BtCancel: TButton;
    BtOK: TButton;
      Bevel1:  TBevel;
    XPManifest: TXPManifest;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure BtCancelClick(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      OkP: boolean;
   end;

implementation

{$R *.dfm}

procedure TFrmPreferences_Anim.BtCancelClick(Sender: TObject);
begin
   OkP := False;
   Close;
end;

procedure TFrmPreferences_Anim.BtOKClick(Sender: TObject);
begin
   OkP := True;
   Close;
end;

procedure TFrmPreferences_Anim.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFrmPreferences_Anim.FormShow(Sender: TObject);
begin
   OkP := False;
end;

end.
