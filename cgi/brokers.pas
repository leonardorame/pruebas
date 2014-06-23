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
  BrookSettings.LogFile := '/var/www/cgi-bin/tir.log';


end.
