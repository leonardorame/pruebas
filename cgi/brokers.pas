unit Brokers;

{$mode objfpc}{$H+}

interface

uses
  BrookFCLEventLogBroker,
  //BrookFCLHttpAppBroker;
  BrookFCLCGIBroker,
  BrookUtils,
  SysUtils;

implementation

initialization
  //BrookSettings.Port := 1024;
  BrookSettings.LogActive := True;
  BrookSettings.LogFile := '/tmp/tir.log';
  BrookSettings.DirectoryForUploads:= '/tmp';


end.
