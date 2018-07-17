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

uses
  System.SysUtils,
  System.Classes;

{$R *.res}

{$LINK 'vdapi.obj'}

procedure Load; cdecl; external name '_Load';
procedure _g_hICAEng; cdecl;
begin

end;

procedure _DriverOpen; cdecl; external name '_DriverOpen@12';
procedure _DriverClose; cdecl; external name '_DriverClose@12';
procedure _DriverInfo; cdecl; external name '_DriverInfo@12';
procedure _DriverPoll; cdecl; external name '_DriverPoll@12';
procedure _DriverQueryInformation; cdecl; external name '_DriverQueryInformation@12';
procedure _DriverSetInformation; cdecl; external name '_DriverSetInformation@12';
procedure _DriverGetLastError; cdecl; external name '_DriverGetLastError@8';


begin
end.
