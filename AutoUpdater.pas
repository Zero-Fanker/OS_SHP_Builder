unit AutoUpdater;

interface

uses Windows, Internet, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, StdCtrls, Dialogs,
   SysUtils, ActiveX, ExtCtrls, Forms;

type
   TAutoUpdater = class(TThread)
      private
         FMmReport: TMemo;
         FLbFilename: TLabel;
         FLbProgress: TLabel;
         FForceRepair: Boolean;
         FBaseDir: string;
         procedure DoMemoRefresh;
         procedure DoLabelRefresh;
      protected
         procedure Execute(); override;
      public
         Finished: boolean;
         RepairDone: boolean;
         constructor Create(const _BaseDir: string; const _MMReport: TMemo; const _LbFilename, _LbPercentage: TLabel; _ForceRepair: boolean);
         procedure WriteString(const _Text: string);
   end;

implementation

constructor TAutoUpdater.Create(const _BaseDir: string; const _MMReport: TMemo; const _LbFilename, _LbPercentage: TLabel; _ForceRepair: boolean);
begin
   inherited Create(true);
   Finished := false;
   Priority := TpHighest;
   FMmReport := _MMReport;
   FLbFilename := _LbFilename;
   FLbProgress := _LBPercentage;
   FForceRepair := _ForceRepair;
   FBaseDir := copy(_BaseDir,1,Length(_BaseDir));
   RepairDone := false;
   Resume;
end;

procedure TAutoUpdater.DoMemoRefresh;
begin
   Application.ProcessMessages;
   FMMReport.Refresh;
   FMMReport.Repaint;
end;

procedure TAutoUpdater.DoLabelRefresh;
begin
   Application.ProcessMessages;
   FLbFileName.Refresh;
   FLbFileName.Repaint;
   FLbProgress.Refresh;
   FLbProgress.Repaint;
end;

procedure TAutoUpdater.Execute;
var
   FileStructureString : string;
   StructureFile: System.Text;
   StructureFilename,BaseDir,Filename: string;
   Node: IXMLNode;
   XMLDocument: IXMLDocument;
   Web : TWebFileDownloader;
   i, Total: integer;
begin
   // Ok, first let's get the file structure document.
   FMMReport.Lines.Clear;
   FLbFilename.Caption := 'Loading File Structure';
   try
      FileStructureString := GetWebContent('http://shpbuilder.ppmsite.com/structure.xml');
   except
      ShowMessage('Warning: Internet Connection Failed. Try again later.');
      ReturnValue := 0;
      Finished := true;
      exit;
   end;
   if Length(FileStructureString) = 0 then
   begin
      ReturnValue := 0;
      Finished := true;
      exit;
   end;
   FLbFilename.Caption := 'File Structure Downloaded';
   BaseDir := IncludeTrailingPathDelimiter(FBaseDir);
   StructureFilename := BaseDir + 'structure.xml';
//   ForceDirectories(BaseDir);
   AssignFile(StructureFile,StructureFilename);
   Rewrite(StructureFile);
   Write(StructureFile,FileStructureString);
   CloseFile(StructureFile);
   FMMReport.Lines.Add('File structure data acquired. Starting procedure to install the program.');
   FMMReport.Refresh;
   // Now, let's read it.
   CoInitialize(nil);
   XMLDocument := TXMLDocument.Create(nil);
   XMLDocument.Active := true;
   XMLDocument.LoadFromFile(StructureFilename);
   // check each item
   Total := XMLDocument.DocumentElement.ChildNodes.Count;
   i := 0;
   Node := XMLDocument.DocumentElement.ChildNodes.FindNode('file');
   repeat
      Filename := BaseDir + Node.Attributes['in'];
      FLbFilename.Caption := Filename;
      FLbProgress.Caption := 'Progress: ' + IntToStr(Trunc((i * 100) / Total)) + '%.';
      Synchronize(DoLabelRefresh);
      if not FileExists(Filename) or FForceRepair then
      begin
         if CompareStr(Filename,ParamStr(0)) = 0 then
         begin
            Web := TWebFileDownloader.Create(Node.Attributes['out'],ExtractFilePath(ParamStr(0)) + 'SHP_BuilderUp.exe');
         end
         else
         begin
            Web := TWebFileDownloader.Create(Node.Attributes['out'],Filename);
         end;
         Sleep(20);
         if Web.WaitFor > 0 then
         begin
            FMMReport.Lines.Add(Filename + ' downloaded.');
            Synchronize(DoMemoRefresh);
         end
         else
         begin
            FMMReport.Lines.Add(Filename + ' failed.');
            Synchronize(DoMemoRefresh);
         end;
         Web.Free;
      end
      else
      begin
         FMMReport.Lines.Add(Filename + ' skipped.');
         Synchronize(DoMemoRefresh);
      end;
      Node := Node.NextSibling;
      inc(i);
   until Node = nil;
   XMLDocument.Active := false;
   DeleteFile(StructureFilename);
   FLbFilename.Caption := '';
   FLbProgress.Caption := 'Progress: 100%.';
   FMMReport.Lines.Add('Installation procedure has been finished.');
   Synchronize(DoLabelRefresh);
   Synchronize(DoMemoRefresh);
   ReturnValue := 1;
   RepairDone := true;
   Finished := true;
end;

procedure TAutoUpdater.WriteString(const _Text: string);
begin
   FMMReport.Lines.Add(_Text);
   Synchronize(DoMemoRefresh);
end;

end.
