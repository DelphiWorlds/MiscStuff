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
  System.SysUtils, System.Classes,
  Winapi.Windows;

procedure _Load; stdcall; external name '_Load';

procedure Log(const AMsg: string);
begin
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
  Log('Citrix called _DriverOpen function');
end;

procedure _DriverClose; stdcall;
begin

end;

procedure _DriverInfo; stdcall;
begin
  Log('Citrix called _DriverInfo function');
end;

procedure _DriverPoll; stdcall;
begin
  Log('Citrix called _DriverPoll function');
end;

procedure _DriverQueryInformation; stdcall;
begin
  Log('Citrix called _DriverQueryInformation function');
end;

procedure _DriverSetInformation; stdcall;
begin
  Log('Citrix called _DriverSetInformation function');
end;

procedure _DriverGetLastError; stdcall;
begin
  Log('Citrix called _DriverGetLastError function');
end;

exports
  Load index 1;

begin
end.
