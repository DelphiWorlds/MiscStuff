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

const
  MAX_ERRORMESSAGE = 288;

type
  PUINT16 = ^UInt16;
  HND = THandle;
  PLIBPROCEDURE = function: UINT32; cdecl;

  _VDINFOCLASS = (
    VdLast_Error, // Added underscore to resolve conflict with VDLASTERROR record type
    VdKillFocus,
    VdSetFocus,
    VdMousePosition,
    VdThinWireCache,
    VdWinCEClipboardCheck,		//  Used by WinCE to check for clipboard changes
    VdDisableModule,
    VdFlush,
    VdInitWindow,
    VdDestroyWindow,
    VdPaint,
    VdThinwireStack,
    VdRealizePaletteFG,			// inform client to realize it's foreground palette
    VdRealizePaletteBG,			// inform client to realize it's background palette
    VdInactivate,				// client is about to lose input focus
    VdGetSecurityAccess,		// cdm security info
    VdSetSecurityAccess,		// cdm security info
    VdGetAudioSecurityAccess,	// cdm audio security info
    VdSetAudioSecurityAccess,	// cdm audio security info
    VdGetPDASecurityAccess,		// cdm PDA security info
    VdSetPDASecurityAccess,		// cdm PDA security info
    VdGetTWNSecurityAccess,		// cdm TWN security info
    VdSetTWNSecurityAccess,		// cdm TWN security info
    VdSendLogoff,
    VdCCShutdown,
    VdSeamlessHostCommand,		// Seamless command call
    VdSeamlessQueryInformation,	// Seamless query call
    VdWindowGotFocus,
    VdSetCursor,				// Set: New cursor from TW. Data - PHGCURSOR
    VdSetCursorPos,				// Set: New cursor position. Data - VPPOINT
    VdEnableState,				// Set/Get driver state (enabled/disabled)
    VdIcaControlCommand,
    VdVirtualChannel,			// Set/Get virtual channel data
    VdWorkArea,					// Set the work area of the application
    VdSupportHighThroughput,
    VdRenderingMode,			// Set/Get the rendering mode (headless client)
    VdPauseResume,				// Pause/Resume commands
    // #ifdef BLT_IS_EXPENSIVE
    VdRedrawNotify,				// Overdrawing suppression.
    // #endif
    VdDisplayCaps,				// Get/Set display capabilities and/or preferred mode
    VdICOSeamlessFunctions,		// Get seamless functions for ICO
    VdPnP,						// Set: Send CLPNP_COMMAND commands inbetween the control VC and the implementation VC (such as VIRTUAL_CCM)
    //* Support for EUEM (Darwin Release For Ohio). This code has been added or
    //* changed to support End User Experience Monitoring functionality. Please do
    //* not change the code in this section without consulting the EUEM team
    //*  Email (at the time of change) "#ENG - Darwin Dev"
    VdEuemStartupTimes,			// Set: EUEM: pass the startup times of shared sessions to the EUEM VD
    VdEuemTwCallback,			// Set: register the EUEM ICA roundtrip callback
                  // function from the thinwire VC to the EUEM VC
                  // End of EUEM support section
    VdResizeHotBitmapCache,		// Set: Tell thinwire driver to resize the hot bitmap cache
    VdSetMonitorLayout,			// Set: Tell thinwire driver to update monitor layout info
    VdGUSBGainFocus,			// Set: Tell Generic USB driver that engine has gained keyboard focus
    VdGUSBLoseFocus,			// Set: Tell Generic USB driver that engine has lost keyboard focus
    VdCreateChannelComms,		// Query: Provide the driver with a pipe to communicate directly with
    VdGetPNPSecurityAccess,		// usb PNP security info
    VdSetPNPSecurityAccess,		// usb PNP security info
    VdReverseSeamless,			// For use with RS specific calls
    VdInfoRequest,				// Used to request information from a VD
    VdReverseSeamlessPartial,   // partial RS packet data used to form a complete RS VC packet
    VdEuemNotifyReconnect,		// Notify EUEM about a reconnect
    VdCHAEnabled,                // Notify Drivers about Enabling/Disabling CHA based on CST recommendation
    VdMTCommand,
    VdSendMouseData,            // Mouse data packets to be sent to host when using VC for mouse data
    VdSendKeyboardData,          // Keyboard type and codes to be sent to host when using VC for keyboard data
    VdSendTouchData,
    VdGUSBSecondAppStarts,
    VdCTXIMEHotKeySetIMEModeInApp,
    VdCTXIMEHotKeySetIMEModeInCDSBar,
    VdCTXIMEQueryInformation,
    VdCTXIMESeamlessQueryInformation,
    VdCTXIMESetDispWMInfo,
    VdCTXIMESetSeamlessWMInfo,
    VdSeamlessResumeLaterCapEnabled
  );
  VDINFOCLASS = _VDINFOCLASS;

  PDLLLINK = ^DLLLINK;
  _DLLLINK = record
    Segment: USHORT;
    DllSize: USHORT;
    ProcCount: USHORT;
    pProcedures: Pointer;
    pData: Pointer;
    pMemory: PUCHAR;
    ModuleName: array[0..13] of Byte;
    pLibMgrCallTable: Pointer;
    ModuleDate: USHORT;
    ModuleTime: USHORT;
    ModuleSize: ULONG;
    pNext: PDLLLINK;
    DllFlags: ULONG;
    LibraryHandle: HND
  end;
  DLLLINK = _DLLLINK;

  PVD = ^VD;
  _VD = record
    ChannelMask: ULONG;
    pWdLink: PDLLLINK;
    LastError: Integer;
    pPrivate: Pointer;
  end;
  VD = _VD;

  PVDOPEN = ^VDOPEN;
  _VDOPEN = record
  	pIniSection: Pointer;
	  pWdLink: PDLLLINK;
	  ///* This field can be either a bit mask of supported channels (b0=0) OR
	  ///* it can be the actual number of a supported channel.
	  ///* The correct interpretation will be determined by the WD and hence
	  ///* this field should not be used to set/get any information about the supported channels. */
	  ChannelMask: ULONG;
	  pfnWFEngPoll: PLIBPROCEDURE;
	  pfnStatusMsgProc: PLIBPROCEDURE;
	  hICAEng: HND
  end;
  VDOPEN = _VDOPEN;

  PDLLCLOSE = ^DLLCLOSE;
  _DLLCLOSE = record
    NotUsed: Integer
  end;
  DLLCLOSE = _DLLCLOSE;

  PDLLINFO = ^DLLINFO;
  _DLLINFO = record
    pBuffer: LPBYTE;
    ByteCount: USHORT
  end;
  DLLINFO = _DLLINFO;

  PDLLPOLL = ^DLLPOLL;
  _DLLPOLL = record
    CurrentTime: ULONG          //* current time in msec */
  end;
  DLLPOLL = _DLLPOLL;

  PVDQUERYINFORMATION = ^VDQUERYINFORMATION;
  _VDQUERYINFORMATION = record
	  VdInformationClass: VDINFOCLASS;
	  pVdInformation: LPVOID;
	  VdInformationLength: Integer;
	  VdReturnLength: Integer;
  end;
  VDQUERYINFORMATION = _VDQUERYINFORMATION;

  PVDSETINFORMATION = ^VDSETINFORMATION;
  _VDSETINFORMATION = record
    VdInformationClass: VDINFOCLASS;
    pVdInformation: LPVOID;
    VdInformationLength: Integer;
  end;
  VDSETINFORMATION = _VDSETINFORMATION;

  PVDLASTERROR = ^VDLASTERROR;
  _VDLASTERROR = record
    Error: Integer;
    Msg: array[0..MAX_ERRORMESSAGE - 1] of Char
  end;
  VDLASTERROR = _VDLASTERROR;

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

function _DriverOpen(pVd: PVD; pVdOpen: PVDOPEN; puiSize: PUINT16): Integer; stdcall;
begin
  Log('Citrix called _DriverOpen function');
end;

function _DriverClose(pVd: PVD; pVdClose: PDLLCLOSE; puiSize: PUINT16): Integer; stdcall;
begin

end;

function _DriverInfo(pVd: PVD; pVdInfo: PDLLINFO; puiSize: PUINT16): Integer; stdcall;
begin
  Log('Citrix called _DriverInfo function');
end;

function _DriverPoll(pVd: PVD; pVdPoll: PDLLPOLL; puiSize: PUINT16): Integer; stdcall;
begin
  Log('Citrix called _DriverPoll function');
end;

function _DriverQueryInformation(pVd: PVD; pVdQueryInformation: PVDQUERYINFORMATION; puiSize: PUINT16): Integer; stdcall;
begin
  Log('Citrix called _DriverQueryInformation function');
end;

function _DriverSetInformation(pVd: PVD; pVdSetInformation: PVDSETINFORMATION; puiSize: PUINT16): Integer; stdcall;
begin
  Log('Citrix called _DriverSetInformation function');
end;

function _DriverGetLastError(pVd: PVD; pLastError: PVDLASTERROR): Integer; stdcall;
begin
  Log('Citrix called _DriverGetLastError function');
end;

exports
  Load index 1;

begin
end.
