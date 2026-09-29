#ifndef AppVersion
#define AppVersion "1.0.0"
#endif

[Setup]
AppId={{5E2A89F0-5C18-4E2E-9937-2E82E3273BC6}
AppName=PseudoLearn
AppVersion={#AppVersion}
AppPublisher=PseudoLearn
AppPublisherURL=https://pseudolearn.com
AppSupportURL=https://pseudolearn.com
AppUpdatesURL=https://pseudolearn.com
DefaultDirName={localappdata}\Programs\PseudoLearn
DefaultGroupName=PseudoLearn
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=PseudoLearn-Setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\pseudolearn.exe

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\PseudoLearn"; Filename: "{app}\pseudolearn.exe"
Name: "{autodesktop}\PseudoLearn"; Filename: "{app}\pseudolearn.exe"; Tasks: desktopicon

[Registry]
Root: HKCU; Subkey: "Software\Classes\pseudolearn"; ValueType: string; ValueData: "URL:PseudoLearn Protocol"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\pseudolearn"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\pseudolearn\DefaultIcon"; ValueType: string; ValueData: "{app}\pseudolearn.exe,0"
Root: HKCU; Subkey: "Software\Classes\pseudolearn\shell\open\command"; ValueType: string; ValueData: """{app}\pseudolearn.exe"" ""%1"""

Root: HKCU; Subkey: "Software\Classes\.pseudo"; ValueType: string; ValueData: "PseudoLearn.Document"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PseudoLearn.Document"; ValueType: string; ValueData: "PseudoLearn Document"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PseudoLearn.Document\DefaultIcon"; ValueType: string; ValueData: "{app}\pseudolearn.exe,0"
Root: HKCU; Subkey: "Software\Classes\PseudoLearn.Document\shell\open\command"; ValueType: string; ValueData: """{app}\pseudolearn.exe"" ""%1"""

[Run]
Filename: "{app}\pseudolearn.exe"; Description: "{cm:LaunchProgram,PseudoLearn}"; Flags: nowait postinstall skipifsilent
