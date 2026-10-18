[Setup]
; AppId فريد لتطبيق السويدي للديكور
AppId={{5A8E5C4F-1B2D-4A3C-9F8E-7D6C5B4A3928}
AppName=السويدي للديكور
AppVersion=1.0.2
AppPublisher=El Sweedy
AppPublisherURL=https://elsweedy.com/
AppSupportURL=https://elsweedy.com/support
AppUpdatesURL=https://elsweedy.com/
; التثبيت في LocalAppData حتى يتمكن نظام التحديث التلقائي من استبدال الملفات دون صلاحيات Admin
DefaultDirName={localappdata}\ElSweedyDecor
DisableProgramGroupPage=yes
OutputDir=.\Output
OutputBaseFilename=ElSweedyDecor_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\windows\x64\runner\Release\stream_pay.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\السويدي للديكور"; Filename: "{app}\stream_pay.exe"
Name: "{autodesktop}\السويدي للديكور"; Filename: "{app}\stream_pay.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\stream_pay.exe"; Description: "{cm:LaunchProgram,السويدي للديكور}"; Flags: nowait postinstall; Check: IsNotSilent
Filename: "{app}\stream_pay.exe"; Flags: nowait; Check: IsSilentInstall

[Code]
function IsNotSilent(): Boolean;
begin
  Result := not WizardSilent();
end;

function IsSilentInstall(): Boolean;
begin
  Result := WizardSilent();
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    Exec('taskkill.exe', '/f /im stream_pay.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;
