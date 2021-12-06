unit Config;

interface

Procedure LoadConfig(const _Filename:string);
Procedure SaveConfig(const _Filename:string);

implementation

uses WindowsUtils, SysUtils, FormMain, FormPreferences;

Procedure LoadConfig(const _Filename:string);
var
   f : file;
   key : string[10];
   count : word;
   Temp: integer;
begin
   AssignFile(F,_Filename);  // Open file
   Reset(F,1); // Goto first byte?

   if not EOF(F) then
   begin
      BlockRead(F,Key,SizeOf(Key));
   end
   else
      Key := '0.0';

   if Key = CONFIG_KEY then
   begin
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      end
      else
         FrmMain.Preferences1Click(nil);
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.PalettePreferenceData,Sizeof(FrmMain.PalettePreferenceData));
      end
      else
         FrmMain.Preferences1Click(nil);
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      end
      else
         FrmMain.alg := 0;
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
      end
      else
         FrmMain.savemode := 0;
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
      end
      else
         FrmMain.loadmode := 0;
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.MaxOpenFiles,Sizeof(FrmMain.MaxOpenFiles));
      end
      else
         FrmMain.MaxOpenFiles := 5;
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      if FrmMain.MaxOpenFiles > 0 then
         for count := 0 to (FrmMain.MaxOpenFiles-1) do
         begin
            if not EOF(F) then
            begin
               FrmMain.OpenFilesList[count] := BlockReadString(F);
            end
            else
               FrmMain.OpenFilesList[count] := '';
      end;
      if not EOF(F) then
      begin
         FrmMain.OpenDir := BlockReadString(F);
      end
      else
         FrmMain.OpenDir := FrmMain.OpenSHPDialog.InitialDir;
      if not EOF(F) then
      begin
         FrmMain.SaveDir := BlockReadString(F);
      end
      else
         FrmMain.SaveDir := FrmMain.OpenSHPDialog.InitialDir;
      if not EOF(F) then
      begin
         FrmMain.ImportDir := BlockReadString(F);
      end
      else
         FrmMain.ImportDir := FrmMain.OpenSHPDialog.InitialDir;
      if not EOF(F) then
      begin
         FrmMain.ExportDir := BlockReadString(F);
      end
      else
         FrmMain.ExportDir := FrmMain.OpenSHPDialog.InitialDir;
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.PreviewBrush,Sizeof(Boolean));
      end
      else
         FrmMain.PreviewBrush := true;
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.OtherOptionsData.AutoSelectSHPType,Sizeof(Boolean));
      end
      else
         FrmMain.OtherOptionsData.AutoSelectSHPType := true;
      if not EOF(F) then
      begin
         FrmMain.OtherOptionsData.LastPalettePath := BlockReadString(F);
      end
      else
         FrmMain.OtherOptionsData.LastPalettePath := '';
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.OtherOptionsData.BackgroundEnabled,Sizeof(Boolean));
      end
      else
         FrmMain.OtherOptionsData.BackgroundEnabled := true;
      if not EOF(F) then
      begin
         BlockRead(F,FrmMain.OtherOptionsData.ApplySelOnFrameChanging,Sizeof(Boolean));
      end
      else
         FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      if not EOF(F) then
      begin
         FrmMain.OpenPaletteDir := BlockReadString(F);
      end
      else
         FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
      if not EOF(F) then
      begin
         BlockRead(F,Temp,Sizeof(Integer));
         FrmMain.Height := Temp;
      end
      else
         FrmMain.Height := 660;
      if not EOF(F) then
      begin
         BlockRead(F,Temp,Sizeof(FrmMain.Width));
         FrmMain.Width := Temp;
      end
      else
         FrmMain.Width := 723;
      if not EOF(F) then
      begin
         BlockRead(F,Temp,Sizeof(FrmMain.Left));
         FrmMain.Left := Temp;
      end
      else
         FrmMain.Left := 293;
      if not EOF(F) then
      begin
         BlockRead(F,Temp,Sizeof(FrmMain.Top));
         FrmMain.Top := Temp;
      end
      else
         FrmMain.Top := 34;
   end
   else if (Key = '2.1') then
   begin
      BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      BlockRead(F,FrmMain.PalettePreferenceData,Sizeof(FrmMain.PalettePreferenceData));
      BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      BlockRead(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
      BlockRead(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
      BlockRead(F,FrmMain.MaxOpenFiles,Sizeof(FrmMain.MaxOpenFiles));
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      if FrmMain.MaxOpenFiles > 0 then
         for count := 0 to (FrmMain.MaxOpenFiles-1) do
            FrmMain.OpenFilesList[count] := BlockReadString(F);
      FrmMain.OpenDir := BlockReadString(F);
      FrmMain.SaveDir := BlockReadString(F);
      FrmMain.ImportDir := BlockReadString(F);
      FrmMain.ExportDir := BlockReadString(F);
      BlockRead(F,FrmMain.PreviewBrush,Sizeof(Boolean));
      BlockRead(F,FrmMain.OtherOptionsData.AutoSelectSHPType,Sizeof(Boolean));
      FrmMain.OtherOptionsData.LastPalettePath := BlockReadString(F);
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := BlockReadString(F);
   end
   else if (Key = '1.8') then
   begin
      BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      BlockRead(F,FrmMain.PalettePreferenceData,Sizeof(FrmMain.PalettePreferenceData));
      BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      BlockRead(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
      BlockRead(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
      BlockRead(F,FrmMain.MaxOpenFiles,Sizeof(FrmMain.MaxOpenFiles));
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      if FrmMain.MaxOpenFiles > 0 then
         for count := 0 to (FrmMain.MaxOpenFiles-1) do
            FrmMain.OpenFilesList[count] := BlockReadString(F);
      FrmMain.OpenDir := BlockReadString(F);
      FrmMain.SaveDir := BlockReadString(F);
      FrmMain.ImportDir := BlockReadString(F);
      FrmMain.ExportDir := BlockReadString(F);
      BlockRead(F,FrmMain.PreviewBrush,Sizeof(Boolean));
      BlockRead(F,FrmMain.OtherOptionsData.AutoSelectSHPType,Sizeof(Boolean));
      FrmMain.OtherOptionsData.LastPalettePath := BlockReadString(F);
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
   end
   else if (Key = '1.7') then
   begin
      BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      BlockRead(F,FrmMain.PalettePreferenceData,Sizeof(FrmMain.PalettePreferenceData));
      BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      BlockRead(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
      BlockRead(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
      BlockRead(F,FrmMain.MaxOpenFiles,Sizeof(FrmMain.MaxOpenFiles));
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      if FrmMain.MaxOpenFiles > 0 then
         for count := 0 to (FrmMain.MaxOpenFiles-1) do
            BlockRead(F,FrmMain.OpenFilesList[count],255 * Sizeof(char));
      BlockRead(F,FrmMain.OpenDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.SaveDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.ImportDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.ExportDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.PreviewBrush,Sizeof(Boolean));
      BlockRead(F,FrmMain.OtherOptionsData.AutoSelectSHPType,Sizeof(Boolean));
      FrmMain.OtherOptionsData.LastPalettePath := '';
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
   end
   else if (Key = '1.6') then
   begin
      BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      BlockRead(F,FrmMain.PalettePreferenceData,Sizeof(FrmMain.PalettePreferenceData));
      BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      BlockRead(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
      BlockRead(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
      BlockRead(F,FrmMain.MaxOpenFiles,Sizeof(FrmMain.MaxOpenFiles));
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      if FrmMain.MaxOpenFiles > 0 then
         for count := 0 to (FrmMain.MaxOpenFiles-1) do
            BlockRead(F,FrmMain.OpenFilesList[count],255 * Sizeof(char));
      BlockRead(F,FrmMain.OpenDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.SaveDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.ImportDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.ExportDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.PreviewBrush,Sizeof(Boolean));
      FrmMain.OtherOptionsData.AutoSelectSHPType := true;
      FrmMain.OtherOptionsData.LastPalettePath := '';
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
   end
   else if (Key = '1.5') then
   begin
      BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      FrmMain.InitializePalettePreferences();
      BlockRead(F,FrmMain.PalettePreferenceData.GameSpecific,Sizeof(boolean));
      BlockRead(F,FrmMain.PalettePreferenceData.TSUnitPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSBuildingPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSAnimationPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSCameoPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      BlockRead(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
      BlockRead(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
      BlockRead(F,FrmMain.MaxOpenFiles,Sizeof(FrmMain.MaxOpenFiles));
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      count := 0;
      while count < FrmMain.MaxOpenFiles do
      begin
         BlockRead(F,FrmMain.OpenFilesList[count],255 * Sizeof(char));
         inc(count);
      end;
      BlockRead(F,FrmMain.OpenDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.SaveDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.ImportDir,255 * Sizeof(char));
      BlockRead(F,FrmMain.ExportDir,255 * Sizeof(char));
      FrmMain.PreviewBrush := true;
      FrmMain.OtherOptionsData.AutoSelectSHPType := true;
      FrmMain.OtherOptionsData.LastPalettePath := '';
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
   end
   else if (Key = '1.3') or (Key = '1.4') then
   begin
      BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      FrmMain.InitializePalettePreferences();
      BlockRead(F,FrmMain.PalettePreferenceData.GameSpecific,Sizeof(boolean));
      BlockRead(F,FrmMain.PalettePreferenceData.TSUnitPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSBuildingPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSAnimationPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSCameoPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      BlockRead(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
      BlockRead(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
      BlockRead(F,FrmMain.MaxOpenFiles,Sizeof(FrmMain.MaxOpenFiles));
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      if FrmMain.MaxOpenFiles > 0 then
         for count := 0 to (FrmMain.MaxOpenFiles-1) do
            BlockRead(F,FrmMain.OpenFilesList[count],255 * Sizeof(char));
      FrmMain.OpenDir := FrmMain.OpenSHPDialog.InitialDir;
      FrmMain.SaveDir := FrmMain.OpenDir;
      FrmMain.ImportDir := FrmMain.OpenDir;
      FrmMain.ExportDir := FrmMain.OpenDir;
      FrmMain.PreviewBrush := true;
      FrmMain.OtherOptionsData.AutoSelectSHPType := true;
      FrmMain.OtherOptionsData.LastPalettePath := '';
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
   end
   else if (Key = '1.1') or (Key = '1.0') then
   begin
      BlockRead(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
      FrmMain.InitializePalettePreferences();
      BlockRead(F,FrmMain.PalettePreferenceData.GameSpecific,Sizeof(boolean));
      BlockRead(F,FrmMain.PalettePreferenceData.TSUnitPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSBuildingPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSAnimationPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.PalettePreferenceData.TSCameoPalette.Filename,Sizeof(TPalettePreferenceData_T));
      BlockRead(F,FrmMain.alg,Sizeof(FrmMain.alg));
      FrmMain.savemode := 0;
      FrmMain.loadmode := 0;
      FrmMain.MaxOpenFiles := 5;
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      FrmMain.OpenFilesList[0] := '';
      FrmMain.OpenFilesList[1] := '';
      FrmMain.OpenFilesList[2] := '';
      FrmMain.OpenFilesList[3] := '';
      FrmMain.OpenFilesList[4] := '';
      FrmMain.OpenDir := FrmMain.OpenSHPDialog.InitialDir;
      FrmMain.SaveDir := FrmMain.OpenDir;
      FrmMain.ImportDir := FrmMain.OpenDir;
      FrmMain.ExportDir := FrmMain.OpenDir;
      FrmMain.PreviewBrush := true;
      FrmMain.OtherOptionsData.AutoSelectSHPType := true;
      FrmMain.OtherOptionsData.LastPalettePath := '';
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
   end
   else
   begin
      FrmMain.Alg := DEFAULT_ALG;
      FrmMain.InitializePalettePreferences();
      FrmMain.Preferences1Click(nil);
      FrmMain.MaxOpenFiles := 5;
      SetLength(FrmMain.OpenFilesList,FrmMain.MaxOpenFiles);
      FrmMain.OpenFilesList[0] := '';
      FrmMain.OpenFilesList[1] := '';
      FrmMain.OpenFilesList[2] := '';
      FrmMain.OpenFilesList[3] := '';
      FrmMain.OpenFilesList[4] := '';
      FrmMain.OpenDir := FrmMain.OpenSHPDialog.InitialDir;
      FrmMain.SaveDir := FrmMain.SaveSHPDialog.InitialDir;
      FrmMain.ImportDir := FrmMain.OpenDir;
      FrmMain.ExportDir := FrmMain.OpenDir;
      FrmMain.PreviewBrush := true;
      FrmMain.OtherOptionsData.AutoSelectSHPType := true;
      FrmMain.OtherOptionsData.LastPalettePath := '';
      FrmMain.OtherOptionsData.BackgroundEnabled := true;
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging := true;
      FrmMain.OpenPaletteDir := ExtractFileDir(ParamStr(0)) + '\Palettes\';
   end;
   CloseFile(F);
end;

Procedure SaveConfig(const _Filename:string);
var
   f : file;
   key : string[10];
   count : word;
   Temp: integer;
begin
   EnforceDirectory(ExtractFileDir(_Filename));
   AssignFile(F,_Filename);  // Open file
   Rewrite(F,1); // Goto first byte?

   Key := CONFIG_KEY;
   Blockwrite(F,Key,SizeOf(Key));
   Blockwrite(F,FrmMain.FileAssociationsPreferenceData,Sizeof(FrmMain.FileAssociationsPreferenceData));
   Blockwrite(F,FrmMain.PalettePreferenceData,Sizeof(FrmMain.PalettePreferenceData));
   Blockwrite(F,FrmMain.alg,Sizeof(FrmMain.alg));
   Blockwrite(F,FrmMain.savemode,Sizeof(FrmMain.savemode));
   Blockwrite(F,FrmMain.loadmode,Sizeof(FrmMain.loadmode));
   Blockwrite(F,FrmMain.MaxOpenFiles,sizeof(FrmMain.MaxOpenFiles));
   if FrmMain.MaxOpenFiles > 0 then
      for count := 0 to (FrmMain.MaxOpenFiles - 1) do
        BlockWriteString(F,FrmMain.OpenFilesList[count]);
   BlockWriteString(F,FrmMain.OpenDir);
   BlockWriteString(F,FrmMain.SaveDir);
   BlockWriteString(F,FrmMain.ImportDir);
   BlockWriteString(F,FrmMain.ExportDir);
   Blockwrite(F,FrmMain.PreviewBrush,sizeof(boolean));
   Blockwrite(F,FrmMain.OtherOptionsData.AutoSelectSHPType,sizeof(boolean));
   if not FileExists(FrmMain.OtherOptionsData.LastPalettePath) then
   begin
      FrmMain.OtherOptionsData.LastPalettePath := ExtractFileDir(ParamStr(0)) + '\Palettes\TS\unittem.pal';
   end;
   BlockWriteString(F,FrmMain.OtherOptionsData.LastPalettePath);
   Blockwrite(F,FrmMain.DisableBackGroundColour1.Checked,sizeof(boolean));
   Blockwrite(F,FrmMain.OtherOptionsData.ApplySelOnFrameChanging,sizeof(boolean));
   BlockWriteString(F,FrmMain.OpenPaletteDir);
   BlockWrite(F,FrmMain.Height,sizeof(FrmMain.Height));
   BlockWrite(F,FrmMain.Width,sizeof(FrmMain.Width));
   Temp := FrmMain.Left;
   BlockWrite(F,Temp,sizeof(FrmMain.Left));
   Temp := FrmMain.Top;
   BlockWrite(F,Temp,sizeof(FrmMain.Top));
   CloseFile(F);
end;

end.
