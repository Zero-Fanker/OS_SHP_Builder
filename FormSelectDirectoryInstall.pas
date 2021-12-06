unit FormSelectDirectoryInstall;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, Grids, DirOutln, ExtCtrls, XPMan;

type
  TFrmSelectDirectoryInstall = class(TForm)
    Drive: TDriveComboBox;
    Label1: TLabel;
    Bevel1: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    Directory: TDirectoryListBox;
    XPManifest: TXPManifest;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelectedDir: string;
    OK: boolean;
    procedure SetSelectedDirectory(const _Dir: string);
  end;

implementation

{$R *.dfm}

procedure TFrmSelectDirectoryInstall.BtCancelClick(Sender: TObject);
begin
   OK := false;
   close;
end;

procedure TFrmSelectDirectoryInstall.BtOKClick(Sender: TObject);
begin
   OK := true;
   SelectedDir := Directory.Directory;
   close;
end;

procedure TFrmSelectDirectoryInstall.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFrmSelectDirectoryInstall.SetSelectedDirectory(const _Dir: string);
begin
   SelectedDir := copy(_Dir,1,Length(_Dir));
   Directory.Directory := _Dir;
end;

end.
