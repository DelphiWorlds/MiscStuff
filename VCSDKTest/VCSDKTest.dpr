library VCSDKTest;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$R *.res}

{$LINK 'vdapi.obj'}

uses
  System.SysUtils, System.IOUtils, System.Classes,
  Winapi.Windows;

type
  TFileWriter = class(TStreamWriter)
  private
    FStream: TStream;
  public
    constructor Create(const Filename: string; Append: Boolean = False); overload; virtual;
    destructor Destroy; override;
  end;

{ TFileWriter }

constructor TFileWriter.Create(const Filename: string; Append: Boolean);
var
  LShareMode: Word;
begin
  if TOSVersion.Platform <> TOSVersion.TPlatform.pfiOS then
    LShareMode := fmShareDenyWrite
  else
    LShareMode := 0;
  if (not TFile.Exists(Filename)) or (not Append) then
    FStream := TFileStream.Create(Filename, fmCreate or LShareMode)
  else
  begin
    FStream := TFileStream.Create(Filename, fmOpenWrite or LShareMode);
    FStream.Seek(0, soEnd);
  end;
  inherited Create(FStream);
end;

destructor TFileWriter.Destroy;
begin
  FStream.Free;
  inherited;
end;

var
  FLog: TFileWriter;

procedure _Load; stdcall; external name '_Load';

procedure Log(const AMsg: string);
begin
  if FLog = nil then
    FLog := TFileWriter.Create('C:\Temp\WSTest.log', True);
  FLog.AutoFlush := True;
  FLog.WriteLine(FormatDateTime('yyyy/mm/dd hh:nn:ss.zzz', Now) + ' TEST Citrix VC SDK: ' + AMsg);
  OutputDebugString(PChar('TEST Citrix VC SDK: ' + AMsg));
end;

procedure Load;
begin
  Log('Hooray - Citrix called exported Load function');
  _Load;
end;

procedure _g_hICAEng; stdcall;
begin

end;

procedure _DriverOpen; stdcall;
begin

end;

procedure _DriverClose; stdcall;
begin

end;

procedure _DriverInfo; stdcall;
begin

end;

procedure _DriverPoll; stdcall; stdcall;
begin

end;

procedure _DriverQueryInformation; stdcall;
begin

end;

procedure _DriverSetInformation; stdcall;
begin

end;

procedure _DriverGetLastError; stdcall;
begin

end;

exports
  Load index 1;

begin
end.
