; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Downloads Manager" 
#define MyAppVersion "0.1.0.0"
#define MyAppExeName "DownloadsManager.exe"
#define InstallDir "..\Installer\"
#define Dir "..\DownloadsManager\Bin\Release"
#define Path "..\DownloadsManager\Bin\Release\DownloadsManager.exe"
#define PathToNet "E:\Study\KPI\3 eo?n\DownloadsManager\Installer\"
#define Name GetStringFileInfo(Path, "ProductName")
#define Publisher GetStringFileInfo(Path, "CompanyName")
#define ExeName Name + ".exe" 
#define AppVersion GetFileVersion(Path)
#define URL "https://github.com/john124"
#define GUID "D7710DDD-0239-4281-9421-BBBC8F1FD5EB"


[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{D7710DDD-0239-4281-9421-BBBC8F1FD5EB}
AppName={#MyAppName}
AppVersion={#MyAppVersion}

AppVerName={#MyAppName} {#AppVersion}
VersionInfoVersion={#AppVersion}

;AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir={#InstallDir}
OutputBaseFilename={#MyAppName} v{#AppVersion} Release Setup
Compression=lzma
SolidCompression=yes
;AppName={#Name}
;AppVersion={#AppVersion}
AppPublisher={#Publisher}
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}

[Languages]     
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: {#Path}; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent


[Code]
/////////////////////////////////////////////////////////////////////
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;


/////////////////////////////////////////////////////////////////////
function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;


/////////////////////////////////////////////////////////////////////
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
// Return Values:
// 1 - uninstall string is empty
// 2 - error executing the UnInstallString
// 3 - successfully executed the UnInstallString

  // default return value
  Result := 0;

  // get the uninstall string of the old app
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

/////////////////////////////////////////////////////////////////////
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      UnInstallOldVersion();
    end;
  end;
end;



//
// Enumeration used to specify a .NET framework version 
//
type TDotNetFramework = (
    DotNet_v11_4322,  // .NET Framework 1.1
    DotNet_v20_50727, // .NET Framework 2.0
    DotNet_v30,       // .NET Framework 3.0
    DotNet_v35,       // .NET Framework 3.5
    DotNet_v4_Client, // .NET Framework 4.0 Client Profile
    DotNet_v4_Full,   // .NET Framework 4.0 Full Installation
    DotNet_v45);      // .NET Framework 4.5

//
// Checks whether the specified .NET Framework version and service pack
// is installed (See: http://www.kynosarges.de/DotNetVersion.html)
//
// Parameters:
//   Version     - Required .NET Framework version
//   ServicePack - Required service pack level (0: None, 1: SP1, 2: SP2 etc.)
//
function IsDotNetInstalled(Version: TDotNetFramework; ServicePack: cardinal): boolean;
  var
    KeyName      : string;
    Check45      : boolean;
    Success      : boolean;
    InstallFlag  : cardinal; 
    ReleaseVer   : cardinal;
    ServiceCount : cardinal;
  begin
    // Registry path for the requested .NET Version
    KeyName := 'SOFTWARE\Microsoft\NET Framework Setup\NDP\';

    case Version of
      DotNet_v11_4322:  KeyName := KeyName + 'v1.1.4322';
      DotNet_v20_50727: KeyName := KeyName + 'v2.0.50727';
      DotNet_v30:       KeyName := KeyName + 'v3.0';
      DotNet_v35:       KeyName := KeyName + 'v3.5';
      DotNet_v4_Client: KeyName := KeyName + 'v4\Client';
      DotNet_v4_Full:   KeyName := KeyName + 'v4\Full';
      DotNet_v45:       KeyName := KeyName + 'v4\Full';
    end;

    // .NET 3.0 uses "InstallSuccess" key in subkey Setup
    if (Version = DotNet_v30) then
      Success := RegQueryDWordValue(HKLM, KeyName + '\Setup', 'InstallSuccess', InstallFlag) else
      Success := RegQueryDWordValue(HKLM, KeyName, 'Install', InstallFlag);

    // .NET 4.0/4.5 uses "Servicing" key instead of "SP"
    if (Version = DotNet_v4_Client) or
       (Version = DotNet_v4_Full) or
       (Version = DotNet_v45) then
      Success := Success and RegQueryDWordValue(HKLM, KeyName, 'Servicing', ServiceCount) else
      Success := Success and RegQueryDWordValue(HKLM, KeyName, 'SP', ServiceCount);

    // .NET 4.5 is distinguished from .NET 4.0 by the Release key
    if (Version = DotNet_v45) then
      begin
        Success := Success and RegQueryDWordValue(HKLM, KeyName, 'Release', ReleaseVer);
        Success := Success and (ReleaseVer >= 378389);
      end;
    

    Result := Success and (InstallFlag = 1) and (ServiceCount >= ServicePack);
  end;