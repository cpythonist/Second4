; Make sure to change the paths as per your save location and computer!

#define appName "Second"
#define appVer "4.0"
#define appPublisher "Infinite, Inc."
#define appURL "http://cpythonist.github.io/second/documentation/secondDoc4.0.html"
#define appOutName "second4.exe"
#define WelcomeFile 'welcome.txt'

[Code]
function GetEnvKey(Param: string): string;
begin
  if IsAdminInstallMode then
    Result := 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
  else
    Result := 'Environment';
end;

function CheckAdmin(Param: string): string;
begin
  if IsAdminInstallMode then
  begin
    Result := ExpandConstant('{commonpf64}/Infinite/{#appName}4');
  end
  else
  begin
    Result := ExpandConstant('{localappdata}/Infinite/{#appName}4');
  end
end;

procedure RemovePath(Path: string);
var
  Paths: string;
  Paths2: string;
  P: Integer;
begin
  if RegQueryStringValue(HKCU, 'Environment', 'Path', Paths) then
  begin
    Log(Format('PATH is [%s]', [Paths]));

    P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';');
    if P = 0 then
    begin
      Log(Format('Path [%s] not found in PATH', [Path]));
    end
      else
    begin
      if P > 1 then P := P - 1;
      Delete(Paths, P, Length(Path) + 1);
      Log(Format('Path [%s] removed from PATH => [%s]', [Path, Paths]));

      if RegWriteStringValue(HKCU, 'Environment', 'Path', Paths) then
      begin
        Log('PATH written');
      end
        else
      begin
        Log('Error writing PATH');
      end;
    end;
  end;
  if RegQueryStringValue(HKLM, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', Paths2) then
  begin
    Log(Format('PATH is [%s]', [Paths2]));

    P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths2) + ';');
    if P = 0 then
    begin
      Log(Format('Path [%s] not found in PATH', [Path]));
    end
      else
    begin
      if P > 1 then P := P - 1;
      Delete(Paths2, P, Length(Path) + 1);
      Log(Format('Path [%s] removed from PATH => [%s]', [Path, Paths2]));

      if RegWriteStringValue(HKLM, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', Paths2) then
      begin
        Log('PATH written');
      end
        else
      begin
        Log('Error writing PATH');
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    RemovePath(ExpandConstant('{app}'));
  end;
end;

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId=Second4
AppName={#appName}
AppVersion={#appVer}
;AppVerName={#appName} {#appVer}
AppPublisher={#appPublisher}
AppCopyright=Apache-2.0
AppPublisherURL={#appURL}
AppSupportURL={#appURL}
AppUpdatesURL={#appURL}
DefaultDirName={code:CheckAdmin}
DefaultGroupName={#appName}
DisableProgramGroupPage=auto
DisableWelcomePage=no
VersionInfoCompany={#appPublisher}
VersionInfoCopyright=Apache-2.0
VersionInfoDescription=Second 4.0 Interpreter Setup
VersionInfoOriginalFileName=Second4.0-Setup
VersionInfoVersion=1.0.0.0
LicenseFile=second4\LICENSE.txt
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
Compression=lzma2/ultra64
InternalCompressLevel=ultra
SolidCompression=yes
OutputDir=innoOut
OutputBaseFilename=Second4.0-Setup
SetupIconFile=icons\second4Install.ico
WizardStyle=modern
UninstallDisplayIcon=icons\second4Uninstall.ico
UninstallDisplayName=Second 4 
ChangesEnvironment=yes

[Registry]
Root: HKA; Subkey: {code:GetEnvKey}; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}";  

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: envPath; Description: "Add to PATH variable" 

[Files]
Source: "second4\base.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\certifi\*"; DestDir: "{app}\certifi"; Flags: ignoreversion recursesubdirs
Source: "second4\charset_normalizer\*"; DestDir: "{app}\charset_normalizer"; Flags: ignoreversion recursesubdirs
Source: "second4\fastnumbers\*"; DestDir: "{app}\fastnumbers"; Flags: ignoreversion recursesubdirs
Source: "second4\globalNamespace.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\libcrypto-3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\libffi-8.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\libssl-3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\LICENSE.TXT"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\printStrings.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\psutil\*"; DestDir: "{app}\psutil"; Flags: ignoreversion recursesubdirs
Source: "second4\pyexpat.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\python3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\python311.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\second4.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\select.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\settings.dat"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\unicodedata.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\zstandard\*"; DestDir: "{app}\zstandard"; Flags: ignoreversion recursesubdirs
Source: "second4\_bz2.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_ctypes.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_decimal.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_elementtree.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_hashlib.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_lzma.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_queue.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_socket.pyd"; DestDir: "{app}"; Flags: ignoreversion
Source: "second4\_ssl.pyd"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#appName} 4"; Filename: "{app}\{#appOutName}"
Name: "{autodesktop}\{#appName} 4"; Filename: "{app}\{#appOutName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#appOutName}"; Description: "{cm:LaunchProgram,{#StringChange(appName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent


