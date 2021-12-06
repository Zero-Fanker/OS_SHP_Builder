unit FormFrameSplitter;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, Spin, XPMan;

type
   TFrmFrameSplitter = class(TForm)
      Label1:      TLabel;
      SpeFrameNum: TSpinEdit;
      Label2:      TLabel;
      SpeHorizontal: TSpinEdit;
      Label3:      TLabel;
      SpeVertical: TSpinEdit;
      EdWidth:     TEdit;
      EdHeight:    TEdit;
      Bevel1:      TBevel;
      Label4:      TLabel;
      ComboOrder:  TComboBox;
    BtOK: TButton;
    BtCancel: TButton;
      Label5:      TLabel;
    XPManifest: TXPManifest;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure SpeHorizontalChange(Sender: TObject);
      procedure SpeVerticalChange(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
      procedure BtCancelClick(Sender: TObject);
   private
      { Private declarations }
   public
      InitialWidth, InitialHeight: integer;
      Changed: boolean;
      { Public declarations }
   end;

implementation

{$R *.dfm}

procedure TFrmFrameSplitter.SpeHorizontalChange(Sender: TObject);
begin
   EdWidth.Text := IntToStr(InitialWidth div StrToIntDef(SpeHorizontal.Text, 1));
end;

procedure TFrmFrameSplitter.SpeVerticalChange(Sender: TObject);
begin
   EdHeight.Text := IntToStr(InitialHeight div StrToIntDef(SpeVertical.Text, 1));
end;

procedure TFrmFrameSplitter.FormCreate(Sender: TObject);
begin
   changed := False;
end;

procedure TFrmFrameSplitter.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFrmFrameSplitter.BtOKClick(Sender: TObject);
var
   Temp: integer;
begin
   Temp := StrToIntDef(SpeHorizontal.Text, 1);
   if (Temp > 0) and (Temp <= SpeHorizontal.MaxValue) then
   begin
      Temp := StrToIntDef(SpeVertical.Text, 1);
      if (Temp > 0) and (Temp <= SpeVertical.MaxValue) then
      begin
         Temp := StrToIntDef(SpeFrameNum.Text, 1);
         if (Temp > 0) and (Temp <= SpeFrameNum.MaxValue) then
         begin
            changed := True;
         end;
      end;
   end;
   Close;
end;

procedure TFrmFrameSplitter.BtCancelClick(Sender: TObject);
begin
   Close;
end;

end.
