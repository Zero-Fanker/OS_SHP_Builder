unit WindowsUtils;

interface

uses ShellAPI;

function BlockReadString(var _F: File): string;
procedure BlockWriteString(var _F: File; const _MyString: string);
procedure EnforceDirectory(const _Path: string);
procedure RunAProgram (const _theProgram, _itsParameters, _defaultDirectory : string);
function RunProgram (const _theProgram, _itsParameters, _defaultDirectory : string): TShellExecuteInfo;
function RunAsAdmin(const _Filename: string; const _Parameters: string): Boolean;
procedure OpenHyperlink(_HyperLink: PChar);
function IsDirectoryWriteable(const _AName: string): Boolean;

implementation

uses SysUtils, Windows, Forms;

function BlockReadString(var _F: File): string;
var
   i: integer;
   Buffer: array[0..254] of char;
begin
   BlockRead(_F,Buffer,255 * Sizeof(char));
   i := 0;
   Result := '';
   while Buffer[i] <> #0 do
   begin
      Result := Result + Buffer[i];
      inc(i);
   end;
end;

procedure BlockWriteString(var _F: File; const _MyString: string);
var
   i: integer;
   Buffer: array[0..254] of char;
begin
   i := 1;
   while i <= Length(_MyString) do
   begin
      Buffer[i-1] := _MyString[i];
      inc(i);
   end;
   Buffer[i-1] := #0;
   while i <= 254 do
   begin
      Buffer[i] := #0;
      inc(i);
   end;
   BlockWrite(_F,Buffer,255 * Sizeof(char));
end;

procedure EnforceDirectory(const _Path: string);
var
   UpperPath: string;
begin
   UpperPath := ExtractFileDir(ExcludeTrailingPathDelimiter(_Path));
   if not DirectoryExists(UpperPath) then
   begin
      EnforceDirectory(UpperPath);
   end;
   ForceDirectories(_Path);
end;

procedure RunAProgram (const _theProgram, _itsParameters, _defaultDirectory : string);
var
   rslt     : integer;
   msg      : string;
begin
   rslt := ShellExecute (0, 'open', pChar (_theProgram), pChar (_itsParameters), pChar (_defaultDirectory), sw_ShowNormal);
   if rslt <= 32 then
   begin
      case rslt of
         0,
         se_err_OOM :             msg := 'Out of memory/resources';
         error_File_Not_Found :   msg := 'File "' + _theProgram + '" not found';
         error_Path_Not_Found :   msg := 'Path not found';
         error_Bad_Format :       msg := 'Damaged or invalid exe';
         se_err_AccessDenied :    msg := 'Access denied';
         se_err_NoAssoc,
         se_err_AssocIncomplete : msg := 'Filename association invalid';
         se_err_DDEBusy,
         se_err_DDEFail,
         se_err_DDETimeOut :      msg := 'DDE error';
         se_err_Share :        msg := 'Sharing violation';
         else                    msg := 'no text';
      end; // of case
      raise Exception.Create ('ShellExecute error #' + IntToStr (rslt) + ': ' + msg);
   end;
end;

function RunProgram (const _theProgram, _itsParameters, _defaultDirectory : string): TShellExecuteInfo;
var
   msg : string;
begin
   Result.cbSize := sizeof(TShellExecuteInfo);
   Result.lpFile := pChar(_theProgram);
   Result.lpParameters := pChar(_itsParameters);
   Result.lpDirectory := pChar(_defaultDirectory);
   Result.nShow := sw_ShowNormal;
   Result.fMask := SEE_MASK_NOCLOSEPROCESS;
   Result.Wnd := 0;
   Result.lpVerb := 'open';
   if not ShellExecuteEx(@Result) then
   begin
      if Result.hInstApp <= 32 then
      begin
         case Result.hInstApp of
            0,
            se_err_OOM :             msg := 'Out of memory/resources';
            error_File_Not_Found :   msg := 'File "' + _theProgram + '" not found';
            error_Path_Not_Found :   msg := 'Path not found';
            error_Bad_Format :       msg := 'Damaged or invalid exe';
            se_err_AccessDenied :    msg := 'Access denied';
            se_err_NoAssoc,
            se_err_AssocIncomplete : msg := 'Filename association invalid';
            se_err_DDEBusy,
            se_err_DDEFail,
            se_err_DDETimeOut :      msg := 'DDE error';
            se_err_Share :        msg := 'Sharing violation';
            else                    msg := 'no text';
         end; // of case
         raise Exception.Create ('ShellExecute error #' + IntToStr(Result.hInstApp) + ': ' + msg);
      end;
   end;
end;

// See Step 3: Redesign for UAC Compatibility (UAC): http://msdn.microsoft.com/en-us/library/bb756922.aspx
// Code adapted from: http://stackoverflow.com/questions/923350/delphi-prompt-for-uac-elevation-when-needed
function RunAsAdmin(const _Filename: string; const _Parameters: string): Boolean;
var
   sei: TShellExecuteInfo;
begin
   ZeroMemory(@sei, SizeOf(sei));
   sei.cbSize := SizeOf(TShellExecuteInfo);
   sei.Wnd := 0;
   sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
   sei.lpVerb := PChar('runas');
   sei.lpFile := PChar(_Filename); // PAnsiChar;
   if _Parameters <> '' then
    	sei.lpParameters := PChar(_Parameters); // PAnsiChar;
   sei.nShow := SW_SHOWNORMAL; //Integer;

   Result := ShellExecuteEx(@sei);
end;

procedure OpenHyperlink(_HyperLink: PChar);
begin
   ShellExecute(Application.Handle,nil,_HyperLink,'','',SW_SHOWNORMAL);
end;

function IsDirectoryWriteable(const _AName: string): Boolean;
var
   FileName: String;
   H: THandle;
begin
   FileName := IncludeTrailingPathDelimiter(_AName) + 'chk.tmp';
   H := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_NEW, FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE, 0);
   Result := H <> INVALID_HANDLE_VALUE;
   if Result then
      CloseHandle(H);
end;

end.
